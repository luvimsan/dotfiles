#!/usr/bin/env python3

from datetime import datetime
import requests
import sys
import subprocess
import re
import html
import textwrap
import os
import sqlite3
import time

CACHE_DB = os.path.expanduser("~/.cache/yt-comments.db")

def get_api_key():
    try:
        result = subprocess.run(
            ["pass", "show", "apis/youtube"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return result.stdout.strip().splitlines()[0]
    except subprocess.CalledProcessError:
        print("Error: Could not retrieve API key from pass (apis/youtube)")
        sys.exit(1)

API_KEY = get_api_key()

if len(sys.argv) < 2:
    print("usage: yt-comments.py VIDEO_ID | URL")
    sys.exit(1)

arg = sys.argv[1]
m = re.search(r"v=([^&]+)", arg)
VIDEO_ID = m.group(1) if m else arg

MAX_PAGES = 3
TOP_N = 50
CACHE_TTL = 3600  # 1 hour
COMMENTS_TTL = 3600  # 1 hour

# --- sqlite setup ---

os.makedirs(os.path.dirname(CACHE_DB), exist_ok=True)
conn = sqlite3.connect(CACHE_DB)
cur = conn.cursor()

cur.executescript("""
CREATE TABLE IF NOT EXISTS videos (
    video_id TEXT PRIMARY KEY,
    title TEXT,
    channel_id TEXT,
    channel_name TEXT,
    published_at TEXT,
    views INTEGER,
    likes INTEGER,
    fetched_at INTEGER
);
CREATE TABLE IF NOT EXISTS channels (
    channel_id TEXT PRIMARY KEY,
    subscribers INTEGER,
    fetched_at INTEGER
);
CREATE TABLE IF NOT EXISTS comments (
    video_id TEXT,
    author TEXT,
    text TEXT,
    likes INTEGER,
    fetched_at INTEGER,
    PRIMARY KEY (video_id, author, text)
);
""")
conn.commit()

now = int(time.time())
session = requests.Session()

# --- cache lookups (single pass) ---

cur.execute("SELECT title, channel_id, channel_name, published_at, views, likes, fetched_at FROM videos WHERE video_id=?", (VIDEO_ID,))
video_row = cur.fetchone()

cur.execute("SELECT COUNT(*) FROM comments WHERE video_id=? AND fetched_at > ?", (VIDEO_ID, now - COMMENTS_TTL))
comments_cached_count = cur.fetchone()[0]

video_cached = video_row and (now - video_row[-1] < CACHE_TTL)
comments_cached = comments_cached_count > 0

# --- fetch functions ---

def fetch_video_meta():
    vr = session.get(
        "https://youtube.googleapis.com/youtube/v3/videos",
        params={
            "key": API_KEY,
            "id": VIDEO_ID,
            "part": "snippet,statistics",
        }
    ).json()

    if not vr.get("items"):
        print("Video not found")
        sys.exit(1)

    v = vr["items"][0]
    v_snip = v["snippet"]
    v_stat = v["statistics"]

    return {
        "title": v_snip["title"],
        "channel_id": v_snip["channelId"],
        "channel_name": v_snip["channelTitle"],
        "published_at": v_snip["publishedAt"],
        "views": int(v_stat.get("viewCount", 0)),
        "likes": int(v_stat.get("likeCount", 0)),
    }

def fetch_channel_meta(channel_id):
    cr = session.get(
        "https://youtube.googleapis.com/youtube/v3/channels",
        params={
            "key": API_KEY,
            "id": channel_id,
            "part": "statistics",
        }
    ).json()
    return int(cr["items"][0]["statistics"].get("subscriberCount", 0))

def fetch_comments():
    all_comments = []
    token = None

    for _ in range(MAX_PAGES):
        r = session.get(
            "https://youtube.googleapis.com/youtube/v3/commentThreads",
            params={
                "key": API_KEY,
                "videoId": VIDEO_ID,
                "part": "snippet",
                "maxResults": 50,
                "pageToken": token,
                "textFormat": "plainText",
                "order": "relevance",
            }
        ).json()

        for item in r.get("items", []):
            s = item["snippet"]["topLevelComment"]["snippet"]
            all_comments.append({
                "likes": int(s["likeCount"]),
                "author": s["authorDisplayName"],
                "text": html.unescape(s["textDisplay"]),
            })

        token = r.get("nextPageToken")
        if not token:
            break

    # YouTube already returns by relevance; sort by likes and take top N
    all_comments.sort(key=lambda c: c["likes"], reverse=True)
    return all_comments[:TOP_N]

# --- cold path: parallel fetches ---

video_meta = None
subs = None
top_comments = None

futures = {}

with ThreadPoolExecutor(max_workers=4) as pool:
    if not video_cached:
        futures["video"] = pool.submit(fetch_video_meta)

    if not comments_cached:
        futures["comments"] = pool.submit(fetch_comments)

    # channel fetch depends on channel_id — handle after video resolves
    if not video_cached and "video" in futures:
        video_meta = futures["video"].result()  # wait for video to get channel_id

        cur.execute("SELECT subscribers, fetched_at FROM channels WHERE channel_id=?", (video_meta["channel_id"],))
        chan_row = cur.fetchone()
        channel_cached = chan_row and (now - chan_row[-1] < CACHE_TTL)

        if not channel_cached:
            futures["channel"] = pool.submit(fetch_channel_meta, video_meta["channel_id"])
    else:
        if video_cached:
            title, channel_id, channel_name, published_at, views, likes, _ = video_row
            video_meta = {
                "title": title, "channel_id": channel_id,
                "channel_name": channel_name, "published_at": published_at,
                "views": views, "likes": likes,
            }

        cur.execute("SELECT subscribers, fetched_at FROM channels WHERE channel_id=?", (video_meta["channel_id"],))
        chan_row = cur.fetchone()
        channel_cached = chan_row and (now - chan_row[-1] < CACHE_TTL)

        if not channel_cached:
            futures["channel"] = pool.submit(fetch_channel_meta, video_meta["channel_id"])

    # collect remaining futures
    if "comments" in futures:
        top_comments = futures["comments"].result()

    if "channel" in futures:
        subs = futures["channel"].result()
    else:
        subs = chan_row[0]

# --- write cache for anything freshly fetched ---

if not video_cached and video_meta:
    cur.execute("""
    INSERT OR REPLACE INTO videos VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (VIDEO_ID, video_meta["title"], video_meta["channel_id"],
          video_meta["channel_name"], video_meta["published_at"],
          video_meta["views"], video_meta["likes"], now))

if not channel_cached and subs is not None:
    cur.execute("""
    INSERT OR REPLACE INTO channels VALUES (?, ?, ?)
    """, (video_meta["channel_id"], subs, now))

if top_comments is not None:
    cur.execute("DELETE FROM comments WHERE video_id=?", (VIDEO_ID,))
    cur.executemany("""
    INSERT OR REPLACE INTO comments VALUES (?, ?, ?, ?, ?)
    """, [(VIDEO_ID, c["author"], c["text"], c["likes"], now) for c in top_comments])

conn.commit()

# --- load comments from db only if we didn't just fetch them ---

if top_comments is None:
    cur.execute("""
    SELECT author, text, likes FROM comments
    WHERE video_id=?
    ORDER BY likes DESC
    LIMIT ?
    """, (VIDEO_ID, TOP_N))
    top_comments = [{"author": a, "text": t, "likes": l} for a, t, l in cur.fetchall()]

conn.close()

# --- print ---

dt = datetime.fromisoformat(video_meta["published_at"].replace('Z', '+00:00'))
formatted = dt.strftime("%b %d, %Y at %H:%M")

def fmt(n):
    return f"{n:,}"

print(f"\033[1m{video_meta['title']}\033[0m")
print(f"\033[36m{video_meta['channel_name']}\033[0m")
print(f"\033[2m{formatted}\033[0m")
print(f"\033[2mViews:\033[0m {fmt(video_meta['views'])}   "
      f"\033[2mLikes:\033[0m {fmt(video_meta['likes'])}   "
      f"\033[2mSubscribers:\033[0m {fmt(subs)}")

for i, c in enumerate(top_comments, 1):
    author = c["author"] if isinstance(c, dict) else c[0]
    text   = c["text"]   if isinstance(c, dict) else c[1]
    likes  = c["likes"]  if isinstance(c, dict) else c[2]

    print(f"\033[2m{'='*80}\033[0m")
    star = "⭐ " if i <= 3 else ""
    print(f"{star}\033[1m#{i}\033[0m  \033[33m👍 {likes}\033[0m  \033[36m{author}\033[0m")
    print(f"\033[2m{'-'*80}\033[0m")
    print("\n".join(textwrap.fill(line, 76) for line in text.splitlines()))
    print()
