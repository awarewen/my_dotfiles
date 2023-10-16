#!/usr/bin/bash env

if pgrep -x wvkbd-mobintl; then killall wvkbd-mobintl; else wvkbd-mobintl -L 300; fi
