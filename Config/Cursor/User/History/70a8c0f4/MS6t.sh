#!/usr/bin/env bash

# =============================================================================
# SwitchWall v1.0 - 重构优化版本
# 功能：智能壁纸切换和主题生成工具
# 作者：基于原始switchwall.sh重构
# =============================================================================

set -euo pipefail  # 严格错误处理

# =============================================================================
# 配置常量
# =============================================================================

readonly QUICKSHELL_CONFIG_NAME="ii"
readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
readonly XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

readonly CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
readonly CACHE_DIR="$XDG_CACHE_HOME/quickshell"
readonly STATE_DIR="$XDG_STATE_HOME/quickshell"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SHELL_CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
readonly MATUGEN_DIR="$XDG_CONFIG_HOME/matugen"
readonly TERMINAL_SCHEME="$SCRIPT_DIR/terminal/scheme-base.json"

# 缓存和临时文件路径
readonly SWITCHWALL_CACHE_DIR="$HOME/.cache/switchwall"
readonly TEMP_WALLPAPER_FILE="$SWITCHWALL_CACHE_DIR/wallpaper_path.tmp"

# 性能优化选项
readonly FAST_PROCESSING="${FAST_PROCESSING:-false}"
readonly DEBUG_MODE="${DEBUG_MODE:-false}"

# 视频相关配置
readonly CUSTOM_DIR="$XDG_CONFIG_HOME/hypr/custom"
readonly RESTORE_SCRIPT_DIR="$CUSTOM_DIR/scripts"
readonly RESTORE_SCRIPT="$RESTORE_SCRIPT_DIR/__restore_video_wallpaper.sh"
readonly THUMBNAIL_DIR="$RESTORE_SCRIPT_DIR/mpvpaper_thumbnails"
readonly VIDEO_OPTS="no-audio loop hwdec=auto scale=bilinear interpolation=no video-sync=display-resample panscan=1.0 video-scale-x=1.0 video-scale-y=1.0 video-align-x=0.5 video-align-y=0.5 load-scripts=no"

# 支持的配色方案类型
readonly ALLOWED_SCHEME_TYPES=(
  "scheme-content"
  "scheme-expressive" 
  "scheme-fidelity"
  "scheme-fruit-salad"
  "scheme-monochrome"
  "scheme-neutral"
  "scheme-rainbow"
  "scheme-tonal-spot"
  "auto"
)

# =============================================================================
# 日志和调试函数
# =============================================================================

log_info() {
  echo "[INFO] $*" >&2
}

log_warn() {
  echo "[WARN] $*" >&2
}

log_error() {
  echo "[ERROR] $*" >&2
}

log_debug() {
  if [[ "$DEBUG_MODE" == "true" ]]; then
    echo "[DEBUG] $*" >&2
  fi
}

# =============================================================================
# 工具函数
# =============================================================================

# 检查命令是否存在
command_exists() {
  command -v "$1" &>/dev/null
}

# 获取屏幕尺寸
get_screen_dimensions() {
  local max_width max_height
  max_width=$(hyprctl monitors -j | jq '([.[].width] | max)' | xargs)
  max_height=$(hyprctl monitors -j | jq '([.[].height] | max)' | xargs)
  echo "$max_width $max_height"
}

# 检查是否为视频文件
is_video() {
  local extension="${1##*.}"
  [[ "$extension" =~ ^(mp4|webm|mkv|avi|mov)$ ]] && return 0 || return 1
}

# 确保目录存在
ensure_directory() {
  mkdir -p "$1"
}

# 清理路径字符串
clean_path() {
  local path="$1"
  echo "$path" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^["'\'']*//;s/["'\'']*$//'
}

# 转换为绝对路径
to_absolute_path() {
  local path="$1"
  if [[ "$path" != /* ]]; then
    echo "$(pwd)/$path"
  else
    echo "$path"
  fi
}

# =============================================================================
# 缓存管理函数
# =============================================================================

ensure_cache_dir() {
  ensure_directory "$SWITCHWALL_CACHE_DIR"
}

# 保存壁纸路径到临时文件
save_wallpaper_path_to_temp() {
  local path="$1"
  if [[ -n "$path" ]]; then
    ensure_directory "$(dirname "$TEMP_WALLPAPER_FILE")"
    echo "$path" > "$TEMP_WALLPAPER_FILE"
    log_debug "保存壁纸路径到临时文件: $path"
  fi
}

# 保存缓存壁纸路径到临时文件
save_cached_wallpaper_path_to_temp() {
  local original_path="$1"
  local filename=$(basename "$original_path")
  local cached_path="$SWITCHWALL_CACHE_DIR/$filename"
  if [[ -n "$original_path" && -f "$cached_path" ]]; then
    ensure_directory "$(dirname "$TEMP_WALLPAPER_FILE")"
    echo "$cached_path" > "$TEMP_WALLPAPER_FILE"
    log_debug "保存缓存路径到临时文件: $cached_path"
  fi
}

# 从临时文件读取壁纸路径
get_wallpaper_path_from_temp() {
  if [[ -f "$TEMP_WALLPAPER_FILE" ]]; then
    cat "$TEMP_WALLPAPER_FILE"
  else
    echo ""
  fi
}

# 删除临时文件
remove_temp_wallpaper_file() {
  if [[ -f "$TEMP_WALLPAPER_FILE" ]]; then
    rm "$TEMP_WALLPAPER_FILE"
    log_debug "临时文件已删除"
  fi
}

# =============================================================================
# 图片处理函数
# =============================================================================

# 处理图片：复制到缓存目录并调整尺寸
process_and_cache_image() {
  local source_path="$1"
  local filename=$(basename "$source_path")
  local target_path="$SWITCHWALL_CACHE_DIR/$filename"
  
  log_debug "开始处理图片: $source_path -> $target_path"
  
  # 确保缓存目录存在
  ensure_cache_dir
  
  # 获取屏幕尺寸信息
  read -r max_width max_height < <(get_screen_dimensions)
  
  # 获取原图尺寸
  local img_width img_height
  if is_video "$source_path"; then
    # 视频文件直接复制，不调整尺寸
    cp "$source_path" "$target_path"
    log_info "视频文件已缓存: $filename"
    echo "$target_path"
    return 0
  else
    if ! command_exists identify; then
      log_warn "未找到identify命令，无法获取图片尺寸"
      cp "$source_path" "$target_path"
      echo "$target_path"
      return 0
    fi
    
    img_width=$(identify -format "%w" "$source_path" 2>/dev/null || echo "0")
    img_height=$(identify -format "%h" "$source_path" 2>/dev/null || echo "0")
  fi
  
  # 检查是否需要调整尺寸
  if [[ "$img_width" -lt "$max_width" || "$img_height" -lt "$max_height" ]]; then
    log_debug "图片尺寸需要调整: ${img_width}x${img_height} -> ${max_width}x${max_height}"
    
    # 计算调整后的尺寸，保持宽高比
    local scale_w scale_h scale new_width new_height
    
    if command_exists bc; then
      scale_w=$(echo "scale=2; $max_width / $img_width" | bc)
      scale_h=$(echo "scale=2; $max_height / $img_height" | bc)
      scale=$(echo "scale=2; if ($scale_w > $scale_h) $scale_w else $scale_h" | bc)
      new_width=$(echo "scale=0; $img_width * $scale / 1" | bc)
      new_height=$(echo "scale=0; $img_height * $scale / 1" | bc)
    else
      # 如果没有bc，使用简单的整数计算
      scale_w=$((max_width / img_width))
      scale_h=$((max_height / img_height))
      scale=$((scale_w > scale_h ? scale_w : scale_h))
      new_width=$((img_width * scale))
      new_height=$((img_height * scale))
    fi
    
    # 使用magick命令调整尺寸并复制到缓存
    if command_exists magick; then
      local magick_args=()
      
      if [[ "$FAST_PROCESSING" == "true" ]]; then
        # 快速处理模式：使用最快的设置
        magick_args=(
          "-limit" "memory" "128MB"
          "-limit" "map" "256MB"
          "-filter" "Box"
          "-resize" "${new_width}x${new_height}^"
          "-gravity" "center"
          "-extent" "${max_width}x${max_height}"
          "-quality" "75"
          "-strip"
        )
        log_debug "使用快速处理模式"
      else
        # 标准处理模式：平衡质量和速度
        magick_args=(
          "-limit" "memory" "256MB"
          "-limit" "map" "512MB"
          "-filter" "Triangle"
          "-resize" "${new_width}x${new_height}^"
          "-gravity" "center"
          "-extent" "${max_width}x${max_height}"
          "-quality" "85"
          "-strip"
        )
        log_debug "使用标准处理模式"
      fi
      
      # 执行magick命令
      if magick "$source_path" "${magick_args[@]}" "$target_path"; then
        # 验证生成的图片是否有效
        if [[ -f "$target_path" ]] && magick identify "$target_path" &>/dev/null; then
          log_info "图片已调整尺寸并缓存: ${img_width}x${img_height} -> ${max_width}x${max_height}"
        else
          log_warn "magick处理失败，尝试使用备用方法"
          # 备用方法：使用最简化的resize
          if magick "$source_path" -limit memory 64MB -limit map 128MB -filter Box -resize "${max_width}x${max_height}" -quality 70 "$target_path"; then
            log_info "备用方法处理成功"
          else
            log_warn "备用方法也失败，直接复制原图"
            cp "$source_path" "$target_path"
          fi
        fi
      else
        log_warn "magick命令执行失败，直接复制原图"
        cp "$source_path" "$target_path"
      fi
    else
      # 如果没有magick命令，直接复制原图
      cp "$source_path" "$target_path"
      log_warn "未找到magick命令，直接复制原图"
    fi
  else
    # 尺寸足够，直接复制
    cp "$source_path" "$target_path"
    log_info "图片尺寸足够，直接缓存: ${img_width}x${img_height}"
  fi
  
  # 返回缓存文件的路径
  echo "$target_path"
}

# =============================================================================
# 配置管理函数
# =============================================================================

# 从配置文件获取配色方案类型
get_type_from_config() {
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    jq -r '.appearance.palette.type' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "auto"
  else
    echo "auto"
  fi
}

# 检测图片的配色方案类型
detect_scheme_type_from_image() {
  local img="$1"
  if [[ -f "$SCRIPT_DIR/scheme_for_image.py" ]]; then
    "$SCRIPT_DIR/scheme_for_image.py" "$img" 2>/dev/null | tr -d '\n'
  else
    echo "auto"
  fi
}

# 验证配色方案类型
validate_scheme_type() {
  local type="$1"
  for allowed_type in "${ALLOWED_SCHEME_TYPES[@]}"; do
    if [[ "$type" == "$allowed_type" ]]; then
      return 0
    fi
  done
  return 1
}

# 设置壁纸路径到配置文件
set_wallpaper_path() {
  local path="$1"
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    if jq --arg path "$path" '.background.wallpaperPath = $path' "$SHELL_CONFIG_FILE" >"$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"; then
      log_debug "壁纸路径已保存到配置文件: $path"
    else
      log_warn "保存壁纸路径到配置文件失败"
    fi
  fi
  # 同时保存缓存路径到临时文件
  save_cached_wallpaper_path_to_temp "$path"
}

# 设置缩略图路径到配置文件
set_thumbnail_path() {
  local path="$1"
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    if jq --arg path "$path" '.background.thumbnailPath = $path' "$SHELL_CONFIG_FILE" >"$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"; then
      log_debug "缩略图路径已保存到配置文件: $path"
    else
      log_warn "保存缩略图路径到配置文件失败"
    fi
  fi
}

# =============================================================================
# 视频处理函数
# =============================================================================

# 杀死现有的mpvpaper进程
kill_existing_mpvpaper() {
  pkill -f -9 mpvpaper || true
  log_debug "已杀死现有mpvpaper进程"
}

# 创建视频壁纸恢复脚本
create_restore_script() {
  local video_path="$1"
  ensure_directory "$RESTORE_SCRIPT_DIR"
  
  cat >"$RESTORE_SCRIPT.tmp" <<EOF
#!/bin/bash
# Generated by switchwall_1.sh - Don't modify it by yourself.
# Time: $(date)

pkill -f -9 mpvpaper

for monitor in \$(hyprctl monitors -j | jq -r '.[] | .name'); do
    mpvpaper -o "$VIDEO_OPTS" "\$monitor" "$video_path" &
    sleep 0.1
done
EOF
  mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
  chmod +x "$RESTORE_SCRIPT"
  log_debug "视频恢复脚本已创建: $RESTORE_SCRIPT"
}

# 移除恢复脚本
remove_restore() {
  ensure_directory "$RESTORE_SCRIPT_DIR"
  cat >"$RESTORE_SCRIPT.tmp" <<EOF
#!/bin/bash
# The content of this script will be generated by switchwall_1.sh - Don't modify it by yourself.
EOF
  mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
  log_debug "恢复脚本已清空"
}

# 处理视频壁纸
handle_video_wallpaper() {
  local imgpath="$1"
  local cached_imgpath="$2"
  
  ensure_directory "$THUMBNAIL_DIR"
  
  # 检查依赖
  local missing_deps=()
  if ! command_exists mpvpaper; then
    missing_deps+=("mpvpaper")
  fi
  if ! command_exists ffmpeg; then
    missing_deps+=("ffmpeg")
  fi
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "缺少依赖: ${missing_deps[*]}"
    echo "Arch: sudo pacman -S ${missing_deps[*]}"
    
    local action
    action=$(notify-send \
      -a "Wallpaper switcher" \
      -c "im.error" \
      -A "install_arch=Install (Arch)" \
      "Can't switch to video wallpaper" \
      "Missing dependencies: ${missing_deps[*]}")
    
    if [[ "$action" == "install_arch" ]]; then
      kitty -1 sudo pacman -S "${missing_deps[*]}"
      if command_exists mpvpaper && command_exists ffmpeg; then
        notify-send 'Wallpaper switcher' 'Alright, try again!' -a "Wallpaper switcher"
      fi
    fi
    return 1
  fi
  
  # 设置壁纸路径
  set_wallpaper_path "$imgpath"
  
  # 设置视频壁纸
  local monitors
  monitors=$(hyprctl monitors -j | jq -r '.[] | .name')
  for monitor in $monitors; do
    mpvpaper -o "$VIDEO_OPTS" "$monitor" "$cached_imgpath" &
    sleep 0.1
  done
  
  # 提取第一帧用于颜色生成
  local thumbnail="$THUMBNAIL_DIR/$(basename "$cached_imgpath").jpg"
  if ffmpeg -y -i "$cached_imgpath" -vframes 1 "$thumbnail" 2>/dev/null; then
    set_thumbnail_path "$thumbnail"
    create_restore_script "$cached_imgpath"
    return 0
  else
    log_error "无法创建缩略图用于颜色生成"
    remove_restore
    return 1
  fi
}

# =============================================================================
# 主题处理函数
# =============================================================================

# 处理KDE Material You颜色
handle_kde_material_you_colors() {
  # 检查是否启用了Qt应用主题
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    local enable_qt_apps
    enable_qt_apps=$(jq -r '.appearance.wallpaperTheming.enableQtApps' "$SHELL_CONFIG_FILE")
    if [[ "$enable_qt_apps" == "false" ]]; then
      return
    fi
  fi
  
  # 映射配色方案类型
  local kde_scheme_variant="scheme-tonal-spot"  # 默认值
  case "$type_flag" in
    scheme-content|scheme-expressive|scheme-fidelity|scheme-fruit-salad|scheme-monochrome|scheme-neutral|scheme-rainbow|scheme-tonal-spot)
      kde_scheme_variant="$type_flag"
      ;;
  esac
  
  if [[ -f "$XDG_CONFIG_HOME/matugen/templates/kde/kde-material-you-colors-wrapper.sh" ]]; then
    "$XDG_CONFIG_HOME/matugen/templates/kde/kde-material-you-colors-wrapper.sh" --scheme-variant "$kde_scheme_variant"
  fi
}

# 预处理
pre_process() {
  local mode_flag="$1"
  
  # 设置GNOME颜色方案
  if [[ "$mode_flag" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
  elif [[ "$mode_flag" == "light" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
  fi
  
  ensure_directory "$CACHE_DIR/user/generated"
}

# 后处理
post_process() {
  local screen_width="$1"
  local screen_height="$2"
  local wallpaper_path="$3"
  
  handle_kde_material_you_colors &
  
  # 这里可以添加其他后处理逻辑
  log_debug "后处理完成: ${screen_width}x${screen_height}"
}

# =============================================================================
# 主要处理函数
# =============================================================================

# 检查和提示放大
check_and_prompt_upscale() {
  local img="$1"
  read -r min_width_desired min_height_desired < <(get_screen_dimensions)
  
  # 处理图片并缓存
  local cached_path
  cached_path=$(process_and_cache_image "$img")
  
  # 发送通知显示处理结果
  if command_exists notify-send; then
    notify-send "壁纸处理完成" "原图: $img\n缓存: $cached_path\n目标尺寸: ${min_width_desired}x${min_height_desired}" -a "Wallpaper switcher"
  fi
  
  # 返回缓存文件路径
  echo "$cached_path"
}

# 主要切换函数
switch() {
  local imgpath="$1"
  local mode_flag="$2"
  local type_flag="$3"
  local color_flag="$4"
  local color="$5"
  
  log_debug "开始切换壁纸: $imgpath"
  
  # 获取屏幕信息
  local scale screenx screeny screensizey cursorposx cursorposy cursorposy_inverted
  read -r scale screenx screeny screensizey < <(hyprctl monitors -j | jq '.[] | select(.focused) | .scale, .x, .y, .height' | xargs)
  
  cursorposx=$(hyprctl cursorpos -j | jq '.x' 2>/dev/null) || cursorposx=960
  cursorposx=$(bc <<<"scale=0; ($cursorposx - $screenx) * $scale / 1")
  cursorposy=$(hyprctl cursorpos -j | jq '.y' 2>/dev/null) || cursorposy=540
  cursorposy=$(bc <<<"scale=0; ($cursorposy - $screeny) * $scale / 1")
  cursorposy_inverted=$((screensizey - cursorposy))
  
  local matugen_args=()
  local generate_colors_material_args=()
  
  if [[ "$color_flag" == "1" ]]; then
    matugen_args=(color hex "$color")
    generate_colors_material_args=(--color "$color")
  else
    if [[ -z "$imgpath" ]]; then
      log_error "未提供图片路径"
      exit 1
    fi
    
    # 处理图片并获取缓存路径
    local cached_imgpath
    cached_imgpath=$(check_and_prompt_upscale "$imgpath")
    kill_existing_mpvpaper
    
    if is_video "$cached_imgpath"; then
      if handle_video_wallpaper "$imgpath" "$cached_imgpath"; then
        local thumbnail="$THUMBNAIL_DIR/$(basename "$cached_imgpath").jpg"
        matugen_args=(image "$thumbnail")
        generate_colors_material_args=(--path "$thumbnail")
      else
        exit 1
      fi
    else
      matugen_args=(image "$cached_imgpath")
      generate_colors_material_args=(--path "$cached_imgpath")
      # 更新壁纸路径到配置
      set_wallpaper_path "$imgpath"
      remove_restore
    fi
  fi
  
  # 确定模式
  if [[ -z "$mode_flag" ]]; then
    local current_mode
    current_mode=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")
    if [[ "$current_mode" == "prefer-dark" ]]; then
      mode_flag="dark"
    else
      mode_flag="light"
    fi
  fi
  
  # 构建参数
  [[ -n "$mode_flag" ]] && matugen_args+=(--mode "$mode_flag") && generate_colors_material_args+=(--mode "$mode_flag")
  [[ -n "$type_flag" ]] && matugen_args+=(--type "$type_flag") && generate_colors_material_args+=(--scheme "$type_flag")
  generate_colors_material_args+=(--termscheme "$TERMINAL_SCHEME" --blend_bg_fg)
  generate_colors_material_args+=(--cache "$STATE_DIR/user/generated/color.txt")
  
  pre_process "$mode_flag"
  
  # 检查是否启用了应用和shell主题
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    local enable_apps_shell
    enable_apps_shell=$(jq -r '.appearance.wallpaperTheming.enableAppsAndShell' "$SHELL_CONFIG_FILE")
    if [[ "$enable_apps_shell" == "false" ]]; then
      log_info "应用和shell主题已禁用，跳过matugen和颜色生成"
      return
    fi
  fi
  
  # 执行matugen
  if command_exists matugen; then
    matugen "${matugen_args[@]}"
  else
    log_warn "未找到matugen命令"
  fi
  
  # 生成颜色
  if [[ -n "$ILLOGICAL_IMPULSE_VIRTUAL_ENV" && -f "$SCRIPT_DIR/generate_colors_material.py" ]]; then
    source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate"
    python3 "$SCRIPT_DIR/generate_colors_material.py" "${generate_colors_material_args[@]}" \
      >"$STATE_DIR"/user/generated/material_colors.scss
    deactivate
  else
    log_warn "未找到Python环境或颜色生成脚本"
  fi
  
  # 应用颜色
  if [[ -f "$SCRIPT_DIR/applycolor.sh" ]]; then
    "$SCRIPT_DIR"/applycolor.sh
  else
    log_warn "未找到applycolor.sh脚本"
  fi
  
  # 后处理
  read -r max_width_desired max_height_desired < <(get_screen_dimensions)
  post_process "$max_width_desired" "$max_height_desired" "$cached_imgpath"
  
  log_info "壁纸切换完成"
}

# =============================================================================
# 参数解析和主函数
# =============================================================================

# 显示帮助信息
show_help() {
  cat <<EOF
SwitchWall v1.0 - 智能壁纸切换工具

用法: $0 [选项] [图片路径]

选项:
  --mode <dark|light>     设置颜色模式
  --type <scheme>         设置配色方案类型
  --color <hex>           使用指定颜色
  --image <path>          指定图片路径
  --noswitch              使用当前壁纸
  --show-current          显示当前壁纸信息
  --clear-temp            清除临时文件
  --show-cache            显示缓存信息
  --help                  显示此帮助信息

环境变量:
  FAST_PROCESSING=true    启用快速图片处理模式
  DEBUG_MODE=true         启用调试模式

示例:
  $0                                    # 交互式选择壁纸
  $0 --image /path/to/image.jpg        # 指定图片
  $0 --color "#ff0000"                 # 使用红色
  FAST_PROCESSING=true $0              # 快速模式
EOF
}

# 显示当前壁纸信息
show_current_wallpaper() {
  local current_path
  current_path=$(get_wallpaper_path_from_temp)
  if [[ -n "$current_path" ]]; then
    echo "当前临时文件中的壁纸路径: $current_path"
    if [[ -f "$current_path" ]]; then
      echo "文件存在: 是"
      if command_exists identify; then
        local size
        size=$(identify -format "%wx%h" "$current_path" 2>/dev/null)
        echo "文件尺寸: $size"
      fi
    else
      echo "文件存在: 否"
    fi
  else
    echo "临时文件中没有保存的壁纸路径"
  fi
}

# 显示缓存信息
show_cache_info() {
  if [[ -d "$SWITCHWALL_CACHE_DIR" ]]; then
    echo "缓存目录: $SWITCHWALL_CACHE_DIR"
    if [[ "$(ls -A "$SWITCHWALL_CACHE_DIR" 2>/dev/null)" ]]; then
      echo "缓存文件列表:"
      for cached_file in "$SWITCHWALL_CACHE_DIR"/*; do
        if [[ -f "$cached_file" ]]; then
          echo "  - $(basename "$cached_file")"
          if command_exists identify; then
            local cached_size
            cached_size=$(identify -format "%wx%h" "$cached_file" 2>/dev/null)
            echo "    尺寸: $cached_size"
          fi
        fi
      done
    else
      echo "缓存目录为空"
    fi
  else
    echo "缓存目录不存在"
  fi
}

# 获取新图片路径
get_new_image_path() {
  local new_imgpath
  
  # 切换到壁纸目录
  cd "$(xdg-user-dir PICTURES)/Wallpapers/showcase" 2>/dev/null || \
  cd "$(xdg-user-dir PICTURES)/Wallpapers" 2>/dev/null || \
  cd "$(xdg-user-dir PICTURES)" || return 1
  
  # 使用vimiv选择文件
  new_imgpath="$(vimiv -o %)"
  
  # 清理路径
  new_imgpath=$(clean_path "$new_imgpath")
  new_imgpath=$(to_absolute_path "$new_imgpath")
  
  log_debug "选择的图片路径: '$new_imgpath'"
  
  if [[ -n "$new_imgpath" && -f "$new_imgpath" ]]; then
    echo "$new_imgpath"
  else
    log_warn "无效的图片路径: $new_imgpath"
    return 1
  fi
}

# 处理图片选择逻辑
handle_image_selection() {
  local new_imgpath
  new_imgpath=$(get_new_image_path) || return 1
  
  local new_filename
  new_filename=$(basename "$new_imgpath")
  log_debug "新文件名: $new_filename"
  
  # 获取临时文件中的路径
  local temp_imgpath
  temp_imgpath=$(get_wallpaper_path_from_temp)
  log_debug "临时文件路径: $temp_imgpath"
  
  if [[ -n "$temp_imgpath" && -f "$temp_imgpath" ]]; then
    local temp_filename
    temp_filename=$(basename "$temp_imgpath")
    
    # 比较文件名
    if [[ "$new_filename" == "$temp_filename" ]]; then
      # 文件名相同，检查缓存
      local cached_imgpath="$SWITCHWALL_CACHE_DIR/$new_filename"
      if [[ -f "$cached_imgpath" ]]; then
        echo "$cached_imgpath"
        log_info "文件名相同，使用缓存中的壁纸: $cached_imgpath"
      else
        echo "$new_imgpath"
        log_info "文件名相同但缓存中无同名文件，使用新选择的壁纸: $new_imgpath"
        save_wallpaper_path_to_temp "$new_imgpath"
      fi
    else
      # 文件名不同，使用新文件
      echo "$new_imgpath"
      log_info "使用新选择的壁纸: $new_imgpath"
      save_wallpaper_path_to_temp "$new_imgpath"
    fi
  else
    # 临时文件不存在，使用新文件
    echo "$new_imgpath"
    log_info "临时文件不存在，使用新选择的壁纸: $new_imgpath"
    save_wallpaper_path_to_temp "$new_imgpath"
  fi
}

# 主函数
main() {
  local imgpath=""
  local mode_flag=""
  local type_flag=""
  local color_flag=""
  local color=""
  local noswitch_flag=""
  
  log_debug "SwitchWall v1.0 启动"
  
  # 解析命令行参数
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help)
        show_help
        exit 0
        ;;
      --mode)
        mode_flag="$2"
        shift 2
        ;;
      --type)
        type_flag="$2"
        shift 2
        ;;
      --color)
        color_flag="1"
        if [[ "$2" =~ ^#?[A-Fa-f0-9]{6}$ ]]; then
          color="$2"
          shift 2
        else
          if command_exists hyprpicker; then
            color=$(hyprpicker --no-fancy)
          else
            log_error "未找到hyprpicker命令"
            exit 1
          fi
          shift
        fi
        ;;
      --image)
        imgpath="$2"
        shift 2
        ;;
      --noswitch)
        noswitch_flag="1"
        # 从临时文件或配置文件获取路径
        imgpath=$(get_wallpaper_path_from_temp)
        if [[ -z "$imgpath" ]]; then
          imgpath=$(jq -r '.background.wallpaperPath' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "")
        fi
        # 检查缓存文件
        if [[ -n "$imgpath" && -f "$imgpath" ]]; then
          local filename
          filename=$(basename "$imgpath")
          local cached_path="$SWITCHWALL_CACHE_DIR/$filename"
          if [[ -f "$cached_path" ]]; then
            imgpath="$cached_path"
          fi
        fi
        shift
        ;;
      --show-current)
        show_current_wallpaper
        exit 0
        ;;
      --clear-temp)
        remove_temp_wallpaper_file
        echo "临时文件已清除"
        exit 0
        ;;
      --show-cache)
        show_cache_info
        exit 0
        ;;
      *)
        if [[ -z "$imgpath" ]]; then
          imgpath="$1"
        fi
        shift
        ;;
    esac
  done
  
  # 如果没有设置type_flag，从配置文件获取
  if [[ -z "$type_flag" ]]; then
    type_flag=$(get_type_from_config)
  fi
  
  # 验证type_flag
  if ! validate_scheme_type "$type_flag"; then
    log_warn "无效的配色方案类型 '$type_flag'，使用默认值 'auto'"
    type_flag="auto"
  fi
  
  # 如果没有设置imgpath且不是颜色模式，交互式选择图片
  if [[ -z "$imgpath" && -z "$color_flag" && -z "$noswitch_flag" ]]; then
    imgpath=$(handle_image_selection) || {
      # 如果选择失败，尝试从配置文件读取
      local config_imgpath
      config_imgpath=$(jq -r '.background.wallpaperPath' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "")
      if [[ -n "$config_imgpath" && -f "$config_imgpath" ]]; then
        imgpath="$config_imgpath"
        log_info "使用配置文件中的壁纸: $config_imgpath"
      else
        log_error "无法获取有效的壁纸路径"
        exit 1
      fi
    }
  fi
  
  # 如果type_flag是auto，从图片检测
  if [[ "$type_flag" == "auto" ]]; then
    if [[ -n "$imgpath" && -f "$imgpath" ]]; then
      local detected_type
      detected_type=$(detect_scheme_type_from_image "$imgpath")
      if validate_scheme_type "$detected_type" && [[ "$detected_type" != "auto" ]]; then
        type_flag="$detected_type"
        log_debug "自动检测到配色方案类型: $type_flag"
      else
        log_warn "无法自动检测有效的配色方案，使用默认值 'scheme-tonal-spot'"
        type_flag="scheme-tonal-spot"
      fi
    else
      log_warn "没有图片用于自动检测配色方案，使用默认值 'scheme-tonal-spot'"
      type_flag="scheme-tonal-spot"
    fi
  fi
  
  # 执行切换
  switch "$imgpath" "$mode_flag" "$type_flag" "$color_flag" "$color"
}

# =============================================================================
# 脚本入口
# =============================================================================

# 检查必要的命令
if ! command_exists hyprctl; then
  log_error "未找到hyprctl命令，此脚本需要Hyprland环境"
  exit 1
fi

if ! command_exists jq; then
  log_error "未找到jq命令，请安装jq"
  exit 1
fi

# 执行主函数
main "$@" 