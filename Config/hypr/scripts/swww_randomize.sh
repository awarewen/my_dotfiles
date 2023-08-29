#!/usr/bin/bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix

if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
	echo "Usage:
	$0 <dir containg images>"
	exit 1
fi

# Edit bellow to control the images transition

# This controls (in seconds) when to switch to the next image
INTERVAL=300

while true; do
	find "$1" \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
			sleep $INTERVAL

      COR=$(printf "%02x" $(($RANDOM % 156 + 100)))
      COG=$(printf "%02x" $(($RANDOM % 156 + 100)))
      COB=$(printf "%02x" $(($RANDOM % 156 + 100)))
      ## 清除
      swww clear $COR$COG$COB

## Monitors 
#MONITOR_COUNT=$(hyprctl monitors -j | jq '. | length')  ## 计数
#for ((i=0; i<MONITOR_COUNT;i++)) do
  #MONITOR=$(hyprctl monitors -j | jq -r '.[$i].name')  ## 名称
      #swww img "$img" --outputs DSI-1 \
      #swww img "$img" --outputs $MONITOR \
      swww img "$img" \
                      --transition-fps 60 \
                      --transition-step 250 \
                      --transition-bezier .1,1,.1,.4 \
                      --transition-type any \
                      --transition-duration 4
                      #--transition-pos any \
                      #--transition-pos "$(hyprctl cursorpos)" \

        #done
		done
done

#(https://cubic-bezier.com/#.1,.9,.79,.11)

                      #--transition-bezier .1,1,.1,.1 \ 快速的切换效果不错
                      #--transition-angle \  ## wipe和wave用于控制擦除的角度
                      #--transition-type grow \
