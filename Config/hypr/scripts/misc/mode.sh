#!/usr/bin/env bash

# PATH (关键信息)
RANDWALL=$2
WALLPAPER_DIR=$3
EWW_CONF_DIR=$4

# PS 管理列表
PS=(\
  swww-daemon \
  eww \
  iio-hyprland)

case $1 in
  "close")  # 屏幕合上
    hyprctl dispatch dpms off
    for i in ${!PS[@]}
    do  # Kill
        kill $(pgrep -x "${PS[$i]}")
    done
      ;;

  "open")   # 屏幕打开
    for i in "${!PS[@]}";
    do  # 确保进程处于dead状态，防止冲突
        kill $(pgrep -x "${PS[$i]}")
    done
    # start
    iio-hyprland DSI-1 &                  # 屏幕旋转 优先确定屏幕方向
    swww-daemon &                         # swww-daemon
    eww -c daemon &         # Eww daemon
    sleep 0.3 && hyprctl dispatch dpms on # Dpms on 屏幕亮屏
    sleep 0.5 && eww open bar && eww open bgdecor  # Eww
    sleep 0.5 && $RANDWALL $WALLPAPER_DIR # wallpaper
    ;;
esac
