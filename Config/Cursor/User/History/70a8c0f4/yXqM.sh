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