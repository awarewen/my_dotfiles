#!/usr/bin/bash
if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
	notify-send "Usage:
	$0 <dir containg images>"
	exit 1
fi

find "$1" \
  | while read -r img; do
    echo "$((RANDOM % 1000)):$img"
    done | sort -n | cut -d':' -f2- | tail -n 1 \
| while read -r img; do
	  notify-send "$img"
    COR=$(printf "%02x" $(($RANDOM % 156 + 100)))
    COG=$(printf "%02x" $(($RANDOM % 156 + 100)))
    COB=$(printf "%02x" $(($RANDOM % 156 + 100)))
    swww clear $COR$COG$COB
    swww img "$img" \
                  --transition-fps 60 \
                  --transition-step 250 \
                  --transition-bezier .1,1,.1,.4 \
                  --transition-type any \
                  --transition-duration 4
done
