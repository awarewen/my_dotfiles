#!/usr/bin/env bash

DIST_DIR="$HOME/.cache/ags/notifications"
INTERVAL_TIME=600

while true; do
  if [ -d "$DIST_DIR" ]; then
    rm -r "$DIST_DIR"
  fi
  sleep $INTERVAL_TIME
done
