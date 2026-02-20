#!/usr/bin/env python3

from datetime import datetime
import requests
import sys
import re
import html
import textwrap
import os
import heapq
import itertools
import sqlite3
import time

# config

CONFIG = os.path.expanduser("~/.config/yt-comments/config")
CACHE_DB = os.path.expanduser("~/.cache/yt-comments.db")

API_KEY = None
if os.path.exists(CONFIG):
    with open(CONFIG) as f:
        for line in f:
            if line.startswith("API_KEY="):
                API_KEY = line.split("=", 1)[1].strip()

if not API_KEY:
    print("Error: API_KEY not set in ~/.config/yt-comments/config")
    sys.exit(1)

if len(sys.argv) < 2:
    print("usage: yt-comments.py VIDEO_ID | URL")
    sys.exit(1)

arg = sys.argv[1]
m = re.search(r"v=([^&]+)", arg)
VIDEO_ID = m.group(1) if m else arg

MAX_PAGES = 3
TOP_N = 50
CACHE_TTL = 3600  # 1 hour

# sqlite setup
os.makedirs(os.path.dirname(CACHE_DB), exist_ok=True)
conn = sqlite3.connect(CACHE_DB)
cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS videos (
    video_id TEXT PRIMARY KEY,
    title TEXT,
    channel_id TEXT,
    channel_name TEXT,
    published_at TEXT,
    views INTEGER,
    likes INTEGER,
    fetched_at INTEGER
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS channels (
    channel_id TEXT PRIMARY KEY,
    subscribers INTEGER,
    fetched_at INTEGER
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS comments (
    video_id TEXT,
    author TEXT,
    text TEXT,
    likes INTEGER,
    PRIMARY KEY (video_id, author, text)
)
""")

conn.commit()

now = int(time.time())

session = requests.Session()

# video metadata (cache)
cur.execute("SELECT * FROM videos WHERE video_id=?", (VIDEO_ID,))
row = cur.fetchone()

if row and now - row[-1] < CACHE_TTL:
    title, channel_id, channel_name, published_at, views, likes = row[1:7]
else:
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

    title = v_snip["title"]
    channel_id = v_snip["channelId"]
    channel_name = v_snip["channelTitle"]
    published_at = v_snip["publishedAt"]
    views = int(v_stat.get("viewCount", 0))
    likes = int(v_stat.get("likeCount", 0))

    cur.execute("""
    INSERT OR REPLACE INTO videos VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (VIDEO_ID, title, channel_id, channel_name,
          published_at, views, likes, now))
    conn.commit()

# channel metadata (cache)
cur.execute("SELECT * FROM channels WHERE channel_id=?", (channel_id,))
row = cur.fetchone()

if row and now - row[-1] < CACHE_TTL:
    subs = row[1]
else:
    cr = session.get(
        "https://youtube.googleapis.com/youtube/v3/channels",
        params={
            "key": API_KEY,
            "id": channel_id,
            "part": "statistics",
        }
    ).json()

    subs = int(cr["items"][0]["statistics"].get("subscriberCount", 0))

    cur.execute("""
    INSERT OR REPLACE INTO channels VALUES (?, ?, ?)
    """, (channel_id, subs, now))
    conn.commit()

# comments (cache)
cur.execute("SELECT COUNT(*) FROM comments WHERE video_id=?", (VIDEO_ID,))
count = cur.fetchone()[0]

if count == 0:
    heap = []
    counter = itertools.count()
    token = None
    page_count = 0

    while page_count < MAX_PAGES:
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

            comment = {
                "likes": int(s["likeCount"]),
                "author": s["authorDisplayName"],
                "text": html.unescape(s["textDisplay"]),
            }

            entry = (comment["likes"], next(counter), comment)

            if len(heap) < TOP_N:
                heapq.heappush(heap, entry)
            else:
                if comment["likes"] > heap[0][0]:
                    heapq.heapreplace(heap, entry)

        token = r.get("nextPageToken")
        if not token:
            break

        page_count += 1

    top_comments = sorted(heap, key=lambda x: x[0], reverse=True)
    top_comments = [c[2] for c in top_comments]

    for c in top_comments:
        cur.execute("""
        INSERT OR REPLACE INTO comments VALUES (?, ?, ?, ?)
        """, (VIDEO_ID, c["author"], c["text"], c["likes"]))

    conn.commit()

# load comments from db
cur.execute("""
SELECT author, text, likes FROM comments
WHERE video_id=?
ORDER BY likes DESC
LIMIT ?
""", (VIDEO_ID, TOP_N))

top_comments = cur.fetchall()

# print
dt = datetime.fromisoformat(published_at.replace('Z', '+00:00'))
formatted = dt.strftime("%b %d, %Y at %H:%M")

def fmt(n):
    return f"{n:,}"

print(f"\033[1m{title}\033[0m")
print(f"\033[36m{channel_name}\033[0m")
print(f"\033[2m{formatted}\033[0m")
print(f"\033[2mViews:\033[0m {fmt(views)}   "
      f"\033[2mLikes:\033[0m {fmt(likes)}   "
      f"\033[2mSubscribers:\033[0m {fmt(subs)}")

for i, (author, text, likes) in enumerate(top_comments, 1):
    print(f"\033[2m{'='*80}\033[0m")
    star = "⭐ " if i <= 3 else ""
    print(f"{star}\033[1m#{i}\033[0m  \033[33m👍 {likes}\033[0m  \033[36m{author}\033[0m")
    print(f"\033[2m{'-'*80}\033[0m")
    print("\n".join(textwrap.fill(line, 76) for line in text.splitlines()))
    print()

conn.close()

