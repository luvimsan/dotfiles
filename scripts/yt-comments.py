#!/usr/bin/env python3

import json
import os
import sys
import re
import time
from datetime import datetime

CACHE_DIR = os.path.expanduser("~/.cache/yt-comments")
MAX_PAGES = 3
TOP_N = 70
CACHE_TTL = 3600

def get_cache_path(video_id):
    return os.path.join(CACHE_DIR, f"{video_id}.json")

def get_cached_data(video_id):
    cache_path = get_cache_path(video_id)
    if not os.path.exists(cache_path):
        return None
    try:
        with open(cache_path, "r") as f:
            data = json.load(f)
        if time.time() - data["timestamp"] < CACHE_TTL:
            return data
    except (json.JSONDecodeError, IOError):
        pass
    return None

def save_to_cache(video_id, video_meta, subs, comments):
    os.makedirs(CACHE_DIR, exist_ok=True)
    data = {
        "timestamp": time.time(),
        "video_meta": video_meta,
        "subs": subs,
        "top_comments": comments
    }
    with open(get_cache_path(video_id), "w") as f:
        json.dump(data, f)

def fetch_network_data(video_id):
    import requests
    import html
    import subprocess
    from concurrent.futures import ThreadPoolExecutor

    def get_api_key():
        try:
            result = subprocess.run(
                ["pass", "show", "apis/youtube"],
                check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
            )
            return result.stdout.strip().splitlines()[0]
        except subprocess.CalledProcessError:
            print("Error: Could not retrieve API key from pass (apis/youtube)")
            sys.exit(1)

    def fetch_video_and_channel(api_key, vid_id):
        with requests.Session() as session:
            vr = session.get(
                "https://youtube.googleapis.com/youtube/v3/videos",
                params={"key": api_key, "id": vid_id, "part": "snippet,statistics"}
            ).json()

            if not vr.get("items"):
                print("Video not found")
                sys.exit(1)

            v_snip = vr["items"][0]["snippet"]
            v_stat = vr["items"][0]["statistics"]

            meta = {
                "title": v_snip["title"],
                "channel_id": v_snip["channelId"],
                "channel_name": v_snip["channelTitle"],
                "published_at": v_snip["publishedAt"],
                "views": int(v_stat.get("viewCount", 0)),
                "likes": int(v_stat.get("likeCount", 0)),
            }

            cr = session.get(
                "https://youtube.googleapis.com/youtube/v3/channels",
                params={"key": api_key, "id": meta["channel_id"], "part": "statistics"}
            ).json()
            cr_subs = int(cr["items"][0]["statistics"].get("subscriberCount", 0))

            return meta, cr_subs

    def fetch_comments(api_key, vid_id):
        with requests.Session() as session:
            all_comments = []
            token = None
            for _ in range(MAX_PAGES):
                r = session.get(
                    "https://youtube.googleapis.com/youtube/v3/commentThreads",
                    params={
                        "key": api_key, "videoId": vid_id, "part": "snippet,replies",
                        "maxResults": 50, "pageToken": token, "textFormat": "plainText", "order": "relevance",
                    }
                ).json()

                for item in r.get("items", []):
                    s = item["snippet"]["topLevelComment"]["snippet"]
                    is_creator = s.get("authorChannelId", {}).get("value") == s.get("channelId")
                    all_comments.append({
                        "likes": int(s["likeCount"]),
                        "author": s["authorDisplayName"],
                        "text": html.unescape(s["textDisplay"]),
                        "is_creator": is_creator,
                    })
                token = r.get("nextPageToken")
                if not token:
                    break

            all_comments.sort(key=lambda c: c["likes"], reverse=True)
            return all_comments[:TOP_N]

    api_key = get_api_key()

    with ThreadPoolExecutor(max_workers=2) as pool:
        future_vc = pool.submit(fetch_video_and_channel, api_key, video_id)
        future_c = pool.submit(fetch_comments, api_key, video_id)

        video_meta, subs = future_vc.result()
        top_comments = future_c.result()

    return video_meta, subs, top_comments

def main():
    if len(sys.argv) < 2:
        print("usage: yt-comments.py VIDEO_ID | URL")
        sys.exit(1)

    arg = sys.argv[1]
    m = re.search(r"v=([^&]+)", arg)
    video_id = m.group(1) if m else arg

    cached = get_cached_data(video_id)
    if cached:
        video_meta = cached["video_meta"]
        subs = cached["subs"]
        top_comments = cached["top_comments"]
    else:
        video_meta, subs, top_comments = fetch_network_data(video_id)
        save_to_cache(video_id, video_meta, subs, top_comments)

    from rich.console import Console
    from rich.panel import Panel

    console = Console(color_system="truecolor")

    dt = datetime.fromisoformat(video_meta["published_at"].replace('Z', '+00:00'))
    formatted = dt.strftime("%b %d, %Y at %H:%M")

    header_text = (
        f"[bold white]{video_meta['title']}[/bold white]\n"
        f"[cyan]{video_meta['channel_name']}[/cyan] • [dim]{formatted}[/dim]\n\n"
        f"[dim]Views:[/dim] {video_meta['views']:,}   "
        f"[dim]Likes:[/dim] {video_meta['likes']:,}   "
        f"[dim]Subscribers:[/dim] {subs:,}"
    )
    console.print(Panel(header_text, border_style="white", expand=True))

    for i, c in enumerate(top_comments, 1):
        star = "⭐ " if i <= 3 else ""
        author_prefix = "[bold red]🎤 " if c.get("is_creator") else "[bold cyan]"
        author_suffix = "[/]"
        author_display = f"{author_prefix}{c['author']}{author_suffix}"

        meta_info = f"[yellow]👍 {c['likes']:,}[/yellow]"

        panel_title = f"{star}[bold]#{i}[/bold] • {author_display} • {meta_info}"

        panel = Panel(
            c['text'],
            title=panel_title,
            title_align="left",
            border_style="dim",
            expand=True
        )
        console.print(panel)

if __name__ == "__main__":
    main()
