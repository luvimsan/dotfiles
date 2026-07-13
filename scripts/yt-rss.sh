#!/usr/bin/env bash
CHANNEL_ID="$1"
MAX_VIDEOS=50

if [ -z "$CHANNEL_ID" ]; then
    exit 1
fi

CACHE_DIR="$HOME/.cache/newsboat-yt"
mkdir -p "$CACHE_DIR"
CACHE_FILE="$CACHE_DIR/${CHANNEL_ID}.xml"

LATEST_YT_ID=$(curl -s "https://www.youtube.com/feeds/videos.xml?channel_id=$CHANNEL_ID" | grep -oPm1 '(?<=<yt:videoId>)[^<]+')

if [ -f "$CACHE_FILE" ] && [ -n "$LATEST_YT_ID" ]; then
    if grep -q "yt:video:$LATEST_YT_ID" "$CACHE_FILE"; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TEMP_FEED=$(cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>YouTube Feed</title>
  <link href="https://www.youtube.com/channel/$CHANNEL_ID"/>
  <updated>$NOW</updated>
  <id>urn:uuid:yt-$CHANNEL_ID</id>
EOF
)

while read -r row; do
    TITLE=$(echo "$row" | jq -r '.title' | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
    ID=$(echo "$row" | jq -r '.id')
    URL="https://www.youtube.com/watch?v=$ID"

    RAW_DATE=$(echo "$row" | jq -r '.upload_date // empty')
    if [ -n "$RAW_DATE" ]; then
        REFORMATTED_DATE="${RAW_DATE:0:4}-${RAW_DATE:4:2}-${RAW_DATE:6:2}T00:00:00Z"
    else
        REFORMATTED_DATE="$NOW"
    fi

    ENTRY=$(cat <<EOF
  <entry>
    <title>$TITLE</title>
    <link href="$URL"/>
    <id>yt:video:$ID</id>
    <updated>$REFORMATTED_DATE</updated>
  </entry>
EOF
)
    TEMP_FEED="$TEMP_FEED"$'\n'"$ENTRY"
done < <(yt-dlp --playlist-end "$MAX_VIDEOS" "https://www.youtube.com/channel/$CHANNEL_ID" --dump-json --flat-playlist 2>/dev/null)

TEMP_FEED="$TEMP_FEED"$'\n'"</feed>"

echo "$TEMP_FEED" > "$CACHE_FILE"
echo "$TEMP_FEED"
