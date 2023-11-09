#!/usr/bin/env bash

DIST_DIR="$HOME/.cache/ags/notifications"
INTERVAL_TIME=100

while true; do
  if [ -f "$DIST_DIR/notifications.json" ]; then
    rm -r "$DIST_DIR/*"
    rm -r "$DIST_DIR/.*"
  fi
  sleep $INTERVAL_TIME
done
