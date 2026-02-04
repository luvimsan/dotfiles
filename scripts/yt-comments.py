#!/usr/bin/env python3

import requests
import sys
import re
import html
import textwrap
import os
import sqlite3
import time
import json

CACHE_DB = os.path.expanduser("~/.cache/yt-comments.db")
CACHE_TTL = 60 * 60 * 6

CONFIG = os.path.expanduser("~/.config/yt-comments/config")
API_KEY = None
if os.path.exists(CONFIG):
    with open(CONFIG) as f:
        for line in f:
            if line.startswith("API_KEY="):
                API_KEY = line.split("=",1)[1].strip()

if not API_KEY:
    print("Error: API_KEY not set in ~/.config/yt-comments/config")
    sys.exit(1)

if len(sys.argv) < 2:
    print("usage: yt-comments.py VIDEO_ID | URL")
    sys.exit(1)

arg = sys.argv[1]
m = re.search(r"v=([^&]+)", arg)
VIDEO_ID = m.group(1) if m else arg

vr = requests.get(
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
views = int(v_stat.get("viewCount", 0))
likes = int(v_stat.get("likeCount", 0))

# channel metadata
cr = requests.get(
    "https://youtube.googleapis.com/youtube/v3/channels",
    params={
        "key": API_KEY,
        "id": channel_id,
        "part": "statistics",
    }
).json()

subs = int(cr["items"][0]["statistics"].get("subscriberCount", 0))

def fmt(n):
    return f"{n:,}"


print(f"\033[1m{title}\033[0m")
print(f"\033[36m{channel_name}\033[0m")
print(f"\033[2mViews:\033[0m {fmt(views)}   "
      f"\033[2mLikes:\033[0m {fmt(likes)}   "
      f"\033[2mSubscribers:\033[0m {fmt(subs)}")

# add the comments
comments = []
token = None
while True:
    r = requests.get(
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
    if "error" in r:
        print("API error:", r["error"]["message"])
        sys.exit(1)

    for item in r.get("items", []):
        s = item["snippet"]["topLevelComment"]["snippet"]
        comments.append({
            "likes": s["likeCount"],
            "author": s["authorDisplayName"],
            "text": html.unescape(s["textDisplay"]).replace("<br>", "\n"),
        })

    token = r.get("nextPageToken")
    if not token:
        break

comments.sort(key=lambda c: c["likes"], reverse=True)

for i, c in enumerate(comments[:50], 1):
    print(f"\033[2m{'='*80}\033[0m")
    star = "⭐ " if i <= 3 else ""
    print(f"{star}\033[1m#{i}\033[0m  \033[33m👍 {c['likes']}\033[0m  \033[36m{c['author']}\033[0m")
    print(f"\033[2m{'-'*80}\033[0m")
    print("\n".join(textwrap.fill(line, 76) for line in c["text"].splitlines()))
    print()

