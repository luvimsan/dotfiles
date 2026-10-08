#!/usr/bin/env bash
cat "${XDG_RUNTIME_DIR:-/tmp}/volume_status" 2>/dev/null
