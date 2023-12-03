#!/usr/bin/env bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix

## Script setup
# ====================================
PID_FILE=/tmp/wallpaper_script_pid # 脚本 PID 文件
PAUSED=false                       # 暂停切换状态初始化
TIMER=0                            # 计时器初始化
TIMER_MAX=10                       # 计时器上限，图片轮换时间
# ====================================
# swww 切换参数值
OUTPUT=none       # 屏幕输出
IMG_RESIZE=crop   # 图像填充 Def: crop [no,crop,fit]
FULL_COLOR=000000 # 填充颜色 Def: 000000 , Need IMG_RESIZE=fit
FILTER=Lanczos3   # 缩放图像时使用的滤镜 Def: Lanczos3 [Nearest, bilinear, Catmullrom, Mitchell, Lanczos3]
TYPE=random       # 切换过渡 Def: simple [none, simple, fade, left, right, top, bottom, wipe, wave, grow, center, any, outer, random]
STEP=255          # 过渡效果速度 ( TYPE=simple STEP=2 ), Def: 90
FPS=255           # 过渡效果帧 Def: 45
ANGLE=45          # For TYPR=wipe/wave, Def: 45
POS=center        # For TYPE=grow/outer, Def: center ['center', 'top', 'left', 'right', 'bottom', 'top-left', 'top-right', 'bottom-left', 'bottom-right']
DURATION=2.4      # 完成过度效果时间 (单位 s) Def: 3, 不适用于 TYPE=simple
BEZIER=.1,1,.1,.4 #0.85,0,0.15,1 #特别平滑:0,0.55,0.45,1 #.1,1,.1,.4 #.1,1,.1,.1 Def: 54,0,.34,.99 , (https://cubic-bezier.com/#.1,.9,.79,.11, https://easings.net/zh-cn)
WAVE=20,20        # For TYPE=wave, Def: 20,20
## wipe和wave用于控制擦除的角度
# ====================================

function manual_switch_signal { # 注册手动切换信号的处理函数 signal= CONT
    TIMER=0 # 重置计时器
    IMG_PATH="$( random_image_path )"
    #echo "manual_switch_signal"
    #echo PATH: $IMG_PATH
    #echo WALLPAPERS_PATH: $WALLPAPERS_PATH
    swww clear $( generate_random_color )
    sleep 0.2 #  ）
    swww img "$IMG_PATH" $( swww_option )
}
trap 'manual_switch_signal' SIGUSR1

function pid_create { # 创建脚本标识
    if [ ! -f $PID_FILE ]; then # PID_FILE is not exist
      command touch $PID_FILE
      echo $$ > $PID_FILE
    fi
}

function swww_option { # swww options tabel
   local transition_args=(
#     "--outputs"             "$OUTPUT"
#     "--no-resize"           "no"
      "--resize"              "$IMG_RESIZE"
#     "--fill-color"          "$FULL_COLOR"
      "--filter"              "$FILTER"
      "--transition-type"     "$TYPE"
      "--transition-step"     "$STEP"
      "--transition-duration" "$DURATION"
      "--transition-fps"      "$FPS"
      "--transition-angle"    "$ANGLE"
      "--transition-pos"      "$POS"
      "--transition-bezier"   "$BEZIER"
      "--transition-wave"     "$WAVE"
  )
  echo "${transition_args[@]}"
}

function sleep_wait {
  while true; do
      ((TIMER++)) # Add TIMER
      if [ $TIMER -ge $TIMER_MAX ]; then
          TIMER=0 # Reset TIMER
          break
      fi
      sleep 1
  done
}


#random_image_path() { # 读取指定目录下的文件
#  find "$IMG_DIR" -maxdepth 1 -type f -print0 \
#  | shuf -z -n 1 \
#  | xargs -0 echo
#}

function random_image_path { # 读取指定目录下的文件生成随机数组
    # shopt -s globstar # 用于开启 ** 递归匹配 local WALLPAPER=("$IMG_DIR"/**/*)
    local random_file="${WALLPAPERS_PATH[RANDOM % ${#WALLPAPERS_PATH[@]}]}" # 仅匹配有限目录深度的文件
    echo "$random_file"
}


function generate_random_color { # 生成清屏的纯色背景
    printf "%02x%02x%02x" $((RANDOM % 156 + 100)) $((RANDOM % 156 + 100)) $((RANDOM % 156 + 100))
}

function deamon { # wallpaper switch
  while true; do
      IMG_PATH="$( random_image_path )" # 读取指定目录下的文件
      
      swww clear $( generate_random_color ) # 清屏
      
      swww img "$IMG_PATH" $( swww_option ) # 切换壁纸
      
      echo PATH: $IMG_PATH
      echo WALLPAPERS_PATH: $WALLPAPERS_PATH
      sleep_wait # 等待进入下一轮切换
  done
}

case $1 in # Main

  "-d" | "--deamon" ) # 初始化壁纸切换
      pid_create # Function: creat a pid file
      if [[ $# -ne 2 ]]; then
        echo "Usage:
      $0 manual <dir containg images>"
      exit 1
      fi

      WALLPAPERS_PATH=("$2"/*)           # wallpapers path

      if [ -f $PID_FILE ] && [ $(cat $PID_FILE) == $$ ]; then deamon # Function: deamon start
      elif [ -f $PID_FILE ] && [ -d /proc/$(cat $PID_FILE) ]; then
        notify-send "Error: $PID_FILE is exist. $0 is already running. "
        exit 1
      else
        echo "$PID_FILE not found"
        exit 1
      fi
    ;;

  "-m" | "--manual" )    # 手动切换
      if [[ $# -ne 2 ]]; then
        echo "Usage:
        $0 manual <dir containg images>"
        exit 1
      fi

      WALLPAPERS_PATH=("$2"/*) # read wallpapers path
      manual_switch_signal
    ;;

  * )
    echo "Error: Option \"$1\" not found."
    echo "Usage:
    $0 [options] <dir containg images>

    Options:
    -------
       -m, --manual <dir containg images>: 手动切换一次随机壁纸
       -d, --deamon <dir containg images>: 初始化并开始随机切换壁纸

    Signal:
    -------
    kill -STOP \$(cat \$PID_FILE): 发送暂停切换壁纸信号
    kill -CONT \$(cat \$PID_FILE): 发送继续切换壁纸信号
       "
    exit 1
    ;;
esac

## Monitors
# 后续将支持多个屏幕随机壁纸切换包括 横屏+竖屏 横屏+横屏 (或自动检测新屏幕并添加)
# MONITOR_COUNT=$(hyprctl monitors -j | jq '. | length')  ## 计数
# for ((i=0; i<MONITOR_COUNT;i++)) do
# MONITOR=$(hyprctl monitors -j | jq -r '.[$i].name')  ## 名称
# swww img "$img" --outputs $MONITOR \

# 添加功能在全屏应用启动后禁止切换壁纸
# socat - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
