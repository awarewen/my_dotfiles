#!/usr/bin/env bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix

## Script setup
# ====================================
WALLPAPERS_PATH=("$2"/*)           # wallpapers path
PID_FILE=/tmp/wallpaper_script_pid # 脚本 PID 文件
PAUSED=false                       # 暂停切换状态初始化
TIMER=0                            # 计时器初始化
TIMER_MAX=600                       # 计时器上限，图片轮换时间
# ====================================
# swww 切换参数值
OUTPUT=none       # 屏幕输出
IMG_RESIZE=crop   # 图像填充 Def: crop [no,crop,fit]
FULL_COLOR=000000 # 填充颜色 Def: 000000 , Need IMG_RESIZE=fit
FILTER=Lanczos3   # 缩放图像时使用的滤镜 Def: Lanczos3 [Nearest, bilinear, Catmullrom, Mitchell, Lanczos3]
TYPE=random       # 切换过渡 Def: simple [none, simple, fade, left, right, top, bottom, wipe, wave, grow, center, any, outer, random]
STEP=255          # 过渡效果速度 ( TYPE=simple STEP=2 ), Def: 90
DURATION=2.4      # 完成过度效果时间 (单位 s) Def: 3, 不适用于 TYPE=simple
FPS=120           # 过渡效果帧 Def: 45
ANGLE=45          # For TYPR=wipe/wave, Def: 45
POS=center        # For TYPE=grow/outer, Def: center ['center', 'top', 'left', 'right', 'bottom', 'top-left', 'top-right', 'bottom-left', 'bottom-right']
BEZIER=.1,1,.1,.4 # .1,1,.1,.1 Def: 54,0,.34,.99 , (https://cubic-bezier.com/#.1,.9,.79,.11)
WAVE=20,20        # For TYPE=wave, Def: 20,20
## wipe和wave用于控制擦除的角度
# ====================================

function handle_pause_signal { # 注册暂停信号的处理函数 signal= USR1
    if ! $PAUSED; then # 检测脚本标识
      PAUSED=true
      echo "Received pause signal. Pausing wallpaper switch."
    else # switch to paused state
      echo "Already pausing."
      echo "Pause state: $PAUSED"
    fi
}
trap 'handle_pause_signal' SIGUSR2

function handle_resume_signal { # 注册恢复信号的处理函数 signal= USR2
    if $PAUSED; then
        echo "Received resume signal. Resuming wallpaper switch."
        PAUSED=false
        TIMER=0 # 重置计时器
    else
      echo "$PAUSED is not pausing"
    fi
}
trap 'handle_resume_signal' SIGUSR1

function manual_switch_signal { # 注册手动切换信号的处理函数 signal= CONT
    TIMER=0 # 重置计时器
    IMG_PATH="$( read_image_path )"
    echo PATH: $IMG_PATH
    swww clear $( generate_random_color )
    swww img "$IMG_PATH" $( swww_option )
} 
trap 'manual_switch_signal' SIGCONT

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

function sleep_wait { # 通过接受信号来停止切换和恢复切换
  while true; do
      ((TIMER++)) # Add TIMER
      if [ "$PAUSED" = false ] && [ $TIMER -ge $TIMER_MAX ]; then
          TIMER=0 # Reset TIMER
          break
      elif [ "$PAUSED" = true ]; then
          while true; do
              $PAUSED || break # 当接收到 PAUSED=false 信号时结束暂停
              sleep 2;
          done
          TIMER=0 # Reset TIMER
          continue # 进入下一轮计时
      fi
      sleep 1
  done
}


#read_image_path() { # 读取指定目录下的文件
#  find "$IMG_DIR" -maxdepth 1 -type f -print0 \
#  | shuf -z -n 1 \
#  | xargs -0 echo
#}

function read_image_path { # 读取指定目录下的文件生成随机数组
    # shopt -s globstar # 用于开启 ** 递归匹配 local WALLPAPER=("$IMG_DIR"/**/*)
    local random_file="${WALLPAPERS_PATH[RANDOM % ${#WALLPAPERS_PATH[@]}]}" # 仅匹配有限目录深度的文件
    echo "$random_file"
}


function generate_random_color { # 生成清屏的纯色背景
    printf "%02x%02x%02x" $((RANDOM % 156 + 100)) $((RANDOM % 156 + 100)) $((RANDOM % 156 + 100))
}

function deamon { # wallpaper switch
  while true; do
      IMG_PATH="$( read_image_path )" # 读取指定目录下的文件
      
      swww clear $( generate_random_color ) # 清屏

      
      swww img "$IMG_PATH" $( swww_option ) # 切换壁纸
      
      echo PATH: $IMG_PATH
      sleep_wait # 等待进入下一轮切换
  done
}

case $1 in # Main
  "-p" | "--paused" ) # 发送暂停信号
    if [ ! -f $PID_FILE ]; then
      notify-send "switcher is not running. $0 deamon <dir containg images>"
      exit 1
    fi

    kill -USR2 $(cat $PID_FILE)
    exit 0
    ;;

  "-r" | "--resume" ) # 发送继续切换信号
    if [ ! -f $PID_FILE ]; then
      notify-send "switcher is not running. $0 deamon <dir containg images>"
      exit 1
    fi

    kill -USR1 $(cat $PID_FILE)
    exit 0
    ;;

  "-d" | "--deamon" ) # 初始化壁纸切换

    pid_create # Function: creat a pid file

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
    elif [[ ! -d $2 ]]; then
      echo "$2 not found."
    fi

    if [ ! -f $PID_FILE ]; then
      notify-send "deamon is not running. $0 deamon <dir containg images>"
      exit 1
    fi

    kill -CONT $(cat $PID_FILE)
    ;;

  * )
    echo "Error: Option \"$1\" not found."
    echo "Usage:
    $0 [options] <dir containg images>

    Options:
    -------
       -m, --manual <dir containg images>: 手动切换一次随机壁纸
       -d, --deamon <dir containg images>: 初始化并开始随机切换壁纸
       -p, --paused: 发送暂停切换壁纸信号
       -r, --resume: 发送继续切换壁纸信号
       -c, --change-time Number: Default:300 s
       -C, --change-dir:
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
