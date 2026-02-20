#!/usr/bin/env bash

RECORDING_FILE="$HOME/screencast/recording_$(date +%F_%H-%M-%S).mkv"
PIDFILE="/tmp/screencast.pid"
MONITOR=$(pactl info | awk -F': ' '/Default Sink:/ {print $2".monitor"}')

record-720() {
  ffmpeg \
    -f x11grab -framerate 30 -i "$DISPLAY" \
    -f pulse -thread_queue_size 512 -i "$MONITOR" \
    -f pulse -thread_queue_size 512 -i default \
    -filter_complex "[1:a][2:a]amix=inputs=2:duration=longest:dropout_transition=2" \
    -vaapi_device /dev/dri/renderD128 \
    -profile:v high -level 4.2 \
    -vf 'format=nv12,hwupload,scale_vaapi=w=1280:h=720' \
    -c:v h264_vaapi -b:v 4M -maxrate 5M -bufsize 8M -g 48 \
    -c:a aac -b:a 128k \
    "$RECORDING_FILE" > /tmp/ffmpeg.log 2>&1 &


  }

record-1080() {
  ffmpeg \
    -f x11grab -framerate 30 -i "$DISPLAY" \
    -f pulse -thread_queue_size 512 -i "$MONITOR" \
    -f pulse -thread_queue_size 512 -i default \
    -filter_complex "[1:a][2:a]amix=inputs=2:duration=longest:dropout_transition=2" \
    -vaapi_device /dev/dri/renderD128 \
    -profile:v high -level 4.2 \
    -vf 'format=nv12,hwupload,scale_vaapi=w=1920:h=1080' \
    -c:v h264_vaapi -b:v 8M -maxrate 10M -bufsize 16M -g 60 \
    -c:a aac -b:a 160k \
    "$RECORDING_FILE" > /tmp/ffmpeg.log 2>&1 &

  }

if [ -f "$PIDFILE" ]; then
  kill -INT "$(cat "$PIDFILE")" && rm "$PIDFILE"
  pkill -RTMIN+10 dwmblocks
else
  mkdir -p "$(dirname $RECORDING_FILE)"
  input=$(printf "Start\nCancel" | dmenu -i -l 3 -p "Screencast:")
  [[ $input != "Start" ]] && exit 0
  [[ -z $input ]] && exit 0

  record-720
  # record-1080

  echo $! > "$PIDFILE"
  sleep 1
  pkill -RTMIN+10 dwmblocks
fi
