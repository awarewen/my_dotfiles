#!/usr/bin/env bash
# 手动单次切换壁纸

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
	notify-send "Usage:
	$0 <dir containg images>"
	exit 1
fi
    # 读取壁纸路径
    img=$(find "$1" -maxdepth 1 -type f -print0 | shuf -z -n 1)

    COR=$(printf "%02x" $(($RANDOM % 156 + 100)))
    COG=$(printf "%02x" $(($RANDOM % 156 + 100)))
    COB=$(printf "%02x" $(($RANDOM % 156 + 100)))
    # 清屏
    swww clear $COR$COG$COB
    # 切换壁纸
    swww img $img \
      --transition-fps 90 \
      --transition-step 255 \
      --transition-bezier .1,1,.1,.4 \
      --transition-type any \
      --transition-duration 2.4
    # 通知
	  notify-send "壁纸切换" "$img" -u normal -i "$img" -t 5000 # 通知处理
