#!/usr/bin/env bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
	echo "Usage:
	$0 <dir containg images>"
	exit 1
fi

# 获取壁纸文件夹路径
IMG_DIR=$1

# 图片轮换时间
INTERVAL=300


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


# swww 切换可选参数
swww_option() {
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


# 通过接受信号来停止切换和恢复切换
sleep_wait() {
    sleep $INTERVAL

    # 保存sleep pid 用于终止切换
    SLEEP_PID=$!
}

# 读取指定目录下的文件
read_image_path() {
  find "$IMG_DIR" -maxdepth 1 -type f -print0 \
  | shuf -z -n 1 \
  | xargs -0 echo
}

# 生成清屏的纯色背景
generate_random_color() {
    printf "%02x%02x%02x" $((RANDOM % 156 + 100)) $((RANDOM % 156 + 100)) $((RANDOM % 156 + 100))
}

# wallpaper switch
while true; do

  # 读取指定目录下的文件
  IMG_PATH="$( read_image_path )"

  # 清屏
  swww clear $( generate_random_color )

  # 切换壁纸
  swww img "$IMG_PATH" $( swww_option )

  # 等待进入下一轮切换
  sleep_wait
done



# # ======================================================================#
# Funstion < read_image >
# # ======================================================================#

# <find>
# 使用 -print0 选项将 find 的输出以 null 终止的方式打印，以处理文件名中可能包含空格等特殊字符的情况。

# <shuf>
# 命令用于随机排列、选择或抽样输入行，并将结果写入标准输出。它可以用于生成随机数据或对输入数据进行乱序处理。
# @ '-z'    :选项告诉 shuf 使用 null 字符（而不是换行符）作为行分隔符
# @ '-n 1'  :则指定只选择一个随机行。


## Monitors
# 后续将支持多个屏幕随机壁纸切换包括 横屏+竖屏 横屏+横屏 (或自动检测新屏幕并添加)
# MONITOR_COUNT=$(hyprctl monitors -j | jq '. | length')  ## 计数
# for ((i=0; i<MONITOR_COUNT;i++)) do
# MONITOR=$(hyprctl monitors -j | jq -r '.[$i].name')  ## 名称
# swww img "$img" --outputs $MONITOR \

# 添加功能在全屏应用启动后禁止切换壁纸
# socat - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

