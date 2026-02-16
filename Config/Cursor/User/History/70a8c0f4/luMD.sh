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