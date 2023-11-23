#!/usr/bin/env bash

# 用于单次手动切换壁纸

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
	echo "Usage:
	$0 <dir containg images>"
	exit 1
fi

# 获取壁纸文件夹路径
IMG_DIR=$1


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
  # 读取指定目录下的文件
  IMG_PATH="$( read_image_path )"

  # 清屏
  swww clear $( generate_random_color )

  # 切换壁纸
  swww img "$IMG_PATH" $( swww_option )

  # 等待进入下一轮切换
  sleep_wait

  # 通知
	notify-send "壁纸切换" "$img" -u normal -i "$img" -t 5000 # 通知处理
