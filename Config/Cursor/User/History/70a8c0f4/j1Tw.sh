#!/usr/bin/env bash

# =============================================================================
# SwitchWall v1.0 - 重构优化版本
# 功能：智能壁纸切换和主题应用脚本
# 作者：基于原始switchwall.sh重构
# 日期：$(date +%Y-%m-%d)
# =============================================================================

set -euo pipefail  # 严格错误处理

# =============================================================================
# 配置常量
# =============================================================================
readonly QUICKSHELL_CONFIG_NAME="ii"
readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
readonly XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# 路径配置
readonly CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
readonly CACHE_DIR="$XDG_CACHE_HOME/quickshell"
readonly STATE_DIR="$XDG_STATE_HOME/quickshell"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SHELL_CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
readonly MATUGEN_DIR="$XDG_CONFIG_HOME/matugen"
readonly TERMINAL_SCHEME="$SCRIPT_DIR/terminal/scheme-base.json"

# 缓存和临时文件配置
readonly SWITCHWALL_CACHE_DIR="$HOME/.cache/switchwall"
readonly TEMP_WALLPAPER_FILE="$SWITCHWALL_CACHE_DIR/wallpaper_path.tmp"

# 性能优化配置
readonly FAST_PROCESSING="${FAST_PROCESSING:-false}"
readonly ENABLE_DEBUG="${ENABLE_DEBUG:-false}"

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
  if [[ "$ENABLE_DEBUG" == "true" ]]; then
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

# 获取图片尺寸
get_image_dimensions() {
  local image_path="$1"
  if command_exists identify; then
    local width height
    width=$(identify -format "%w" "$image_path" 2>/dev/null || echo "0")
    height=$(identify -format "%h" "$image_path" 2>/dev/null || echo "0")
    echo "$width $height"
  else
    echo "0 0"
  fi
}

# 检查是否为视频文件
is_video() {
  local extension="${1##*.}"
  [[ "$extension" =~ ^(mp4|webm|mkv|avi|mov)$ ]] && return 0 || return 1
}

# 清理路径字符串
clean_path() {
  local path="$1"
  echo "$path" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^["'\'']*//;s/["'\'']*$//'
}

# 确保目录存在
ensure_directory() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    log_debug "创建目录: $dir"
  fi
}

# =============================================================================
# 缓存管理函数
# =============================================================================

# 确保缓存目录存在
ensure_cache_dir() {
  ensure_directory "$SWITCHWALL_CACHE_DIR"
}

# 获取缓存文件路径
get_cache_path() {
  local source_path="$1"
  local filename=$(basename "$source_path")
  echo "$SWITCHWALL_CACHE_DIR/$filename"
}

# 清理过期缓存文件（保留最近10个文件）
cleanup_cache() {
  local max_files=10
  if [[ -d "$SWITCHWALL_CACHE_DIR" ]]; then
    local file_count=$(find "$SWITCHWALL_CACHE_DIR" -type f | wc -l)
    if [[ $file_count -gt $max_files ]]; then
      log_debug "清理缓存文件，保留最近 $max_files 个"
      find "$SWITCHWALL_CACHE_DIR" -type f -printf '%T@ %p\n' | sort -nr | tail -n +$((max_files + 1)) | cut -d' ' -f2- | xargs rm -f 2>/dev/null || true
    fi
  fi
}

# =============================================================================
# 图片处理函数
# =============================================================================

# 优化图片处理参数
get_magick_params() {
  if [[ "$FAST_PROCESSING" == "true" ]]; then
    echo "-limit memory 128MB -limit map 256MB -filter Box -quality 75 -strip"
  else
    echo "-limit memory 256MB -limit map 512MB -filter Triangle -quality 85 -strip"
  fi
}

# 处理图片尺寸调整
process_image_resize() {
  local source_path="$1"
  local target_path="$2"
  local target_width="$3"
  local target_height="$4"
  local source_width="$5"
  local source_height="$6"
  
  local magick_params=$(get_magick_params)
  
  if command_exists magick; then
    log_debug "使用 magick 处理图片: $source_path -> $target_path"
    
    # 计算调整后的尺寸，保持宽高比
    local scale_w scale_h scale new_width new_height
    
    if command_exists bc; then
      scale_w=$(echo "scale=2; $target_width / $source_width" | bc)
      scale_h=$(echo "scale=2; $target_height / $source_height" | bc)
      scale=$(echo "scale=2; if ($scale_w > $scale_h) $scale_w else $scale_h" | bc)
      new_width=$(echo "scale=0; $source_width * $scale / 1" | bc)
      new_height=$(echo "scale=0; $source_height * $scale / 1" | bc)
    else
      # 如果没有 bc，使用简单的整数计算
      scale_w=$((target_width * 100 / source_width))
      scale_h=$((target_height * 100 / source_height))
      if [[ $scale_w -gt $scale_h ]]; then
        scale=$scale_w
      else
        scale=$scale_h
      fi
      new_width=$((source_width * scale / 100))
      new_height=$((source_height * scale / 100))
    fi
    
    # 执行图片处理
    if magick "$source_path" $magick_params -resize "${new_width}x${new_height}^" -gravity center -extent "${target_width}x${target_height}" "$target_path"; then
      log_info "图片已调整尺寸并缓存: ${source_width}x${source_height} -> ${target_width}x${target_height}"
      return 0
    else
      log_warn "magick 处理失败，尝试备用方法"
      # 备用方法：使用更简单的 resize
      if magick "$source_path" -limit memory 64MB -limit map 128MB -filter Box -resize "${target_width}x${target_height}" -quality 70 "$target_path"; then
        log_info "备用方法成功"
        return 0
      else
        log_error "备用方法也失败"
        return 1
      fi
    fi
  else
    log_warn "未找到 magick 命令，直接复制原图"
    cp "$source_path" "$target_path"
    return 0
  fi
}

# 处理图片：复制到缓存目录并调整尺寸
process_and_cache_image() {
  local source_path="$1"
  local target_path=$(get_cache_path "$source_path")
  
  ensure_cache_dir
  
  # 获取屏幕尺寸
  local screen_dims
  screen_dims=$(get_screen_dimensions)
  local max_width=$(echo "$screen_dims" | cut -d' ' -f1)
  local max_height=$(echo "$screen_dims" | cut -d' ' -f2)
  
  # 检查是否为视频文件
  if is_video "$source_path"; then
    log_debug "视频文件，直接复制"
    cp "$source_path" "$target_path"
    echo "$target_path"
    return 0
  fi
  
  # 获取原图尺寸
  local img_dims
  img_dims=$(get_image_dimensions "$source_path")
  local img_width=$(echo "$img_dims" | cut -d' ' -f1)
  local img_height=$(echo "$img_dims" | cut -d' ' -f2)
  
  # 检查是否需要调整尺寸
  if [[ "$img_width" -lt "$max_width" || "$img_height" -lt "$max_height" ]]; then
    log_debug "图片尺寸不足，需要调整: ${img_width}x${img_height} -> ${max_width}x${max_height}"
    if process_image_resize "$source_path" "$target_path" "$max_width" "$max_height" "$img_width" "$img_height"; then
      cleanup_cache
      echo "$target_path"
    else
      log_error "图片处理失败，使用原图"
      cp "$source_path" "$target_path"
      echo "$target_path"
    fi
  else
    log_debug "图片尺寸足够，直接缓存: ${img_width}x${img_height}"
    cp "$source_path" "$target_path"
    echo "$target_path"
  fi
}

# =============================================================================
# 临时文件管理函数
# =============================================================================

# 保存壁纸路径到临时文件
save_wallpaper_path_to_temp() {
  local path="$1"
  if [[ -n "$path" ]]; then
    ensure_directory "$(dirname "$TEMP_WALLPAPER_FILE")"
    echo "$path" > "$TEMP_WALLPAPER_FILE"
    log_debug "保存路径到临时文件: $path"
  fi
}

# 保存缓存壁纸路径到临时文件
save_cached_wallpaper_path_to_temp() {
  local original_path="$1"
  local cached_path=$(get_cache_path "$original_path")
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
    log_debug "删除临时文件"
  fi
}

# =============================================================================
# 配置文件管理函数
# =============================================================================

# 设置壁纸路径到配置文件
set_wallpaper_path() {
  local path="$1"
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    if jq --arg path "$path" '.background.wallpaperPath = $path' "$SHELL_CONFIG_FILE" > "$SHELL_CONFIG_FILE.tmp" 2>/dev/null; then
      mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
      log_debug "更新配置文件中的壁纸路径: $path"
    else
      log_warn "更新配置文件失败"
    fi
  fi
  # 同时保存缓存路径到临时文件
  save_cached_wallpaper_path_to_temp "$path"
}

# 设置缩略图路径到配置文件
set_thumbnail_path() {
  local path="$1"
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    if jq --arg path "$path" '.background.thumbnailPath = $path' "$SHELL_CONFIG_FILE" > "$SHELL_CONFIG_FILE.tmp" 2>/dev/null; then
      mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
      log_debug "更新配置文件中的缩略图路径: $path"
    else
      log_warn "更新缩略图配置文件失败"
    fi
  fi
}

# 从配置文件获取配色方案类型
get_type_from_config() {
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    jq -r '.appearance.palette.type' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "auto"
  else
    echo "auto"
  fi
}

# 验证配色方案类型
validate_scheme_type() {
  local type="$1"
  for valid_type in "${ALLOWED_SCHEME_TYPES[@]}"; do
    if [[ "$type" == "$valid_type" ]]; then
      return 0
    fi
  done
  return 1
}

# =============================================================================
# 图片选择函数
# =============================================================================

# 获取图片选择器路径
get_image_selector() {
  # 按优先级尝试不同的图片选择器
  local selectors=("vimiv" "feh" "sxiv" "imv")
  
  for selector in "${selectors[@]}"; do
    if command_exists "$selector"; then
      echo "$selector"
      return 0
    fi
  done
  
  log_error "未找到可用的图片选择器"
  return 1
}

# 选择新图片
select_new_image() {
  local selector
  if selector=$(get_image_selector); then
    # 切换到壁纸目录
    local wallpaper_dirs=(
      "$(xdg-user-dir PICTURES)/Wallpapers/showcase"
      "$(xdg-user-dir PICTURES)/Wallpapers"
      "$(xdg-user-dir PICTURES)"
    )
    
    local cd_success=false
    for dir in "${wallpaper_dirs[@]}"; do
      if cd "$dir" 2>/dev/null; then
        cd_success=true
        break
      fi
    done
    
    if [[ "$cd_success" == "false" ]]; then
      log_error "无法切换到壁纸目录"
      return 1
    fi
    
    # 根据选择器类型执行不同的命令
    local new_imgpath=""
    case "$selector" in
      "vimiv")
        new_imgpath="$(vimiv -o % 2>/dev/null)"
        ;;
      "feh")
        new_imgpath="$(feh --filelist-verbose --stdin 2>/dev/null | head -n1)"
        ;;
      "sxiv")
        new_imgpath="$(sxiv -o 2>/dev/null | head -n1)"
        ;;
      "imv")
        new_imgpath="$(imv 2>/dev/null | head -n1)"
        ;;
    esac
    
    if [[ -n "$new_imgpath" ]]; then
      # 清理路径
      new_imgpath=$(clean_path "$new_imgpath")
      
      # 如果是相对路径，转换为绝对路径
      if [[ "$new_imgpath" != /* ]]; then
        new_imgpath="$(pwd)/$new_imgpath"
      fi
      
      log_debug "选择的图片: $new_imgpath"
      echo "$new_imgpath"
      return 0
    else
      log_warn "未选择图片"
      return 1
    fi
  else
    return 1
  fi
}

# =============================================================================
# 视频处理函数
# =============================================================================

# 检查视频依赖
check_video_dependencies() {
  local missing_deps=()
  
  if ! command_exists mpvpaper; then
    missing_deps+=("mpvpaper")
  fi
  
  if ! command_exists ffmpeg; then
    missing_deps+=("ffmpeg")
  fi
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "缺少视频依赖: ${missing_deps[*]}"
    echo "安装命令: sudo pacman -S ${missing_deps[*]}"
    
    # 尝试自动安装
    if command_exists pacman; then
      local action
      action=$(notify-send \
        -a "Wallpaper switcher" \
        -c "im.error" \
        -A "install_arch=Install (Arch)" \
        "Can't switch to video wallpaper" \
        "Missing dependencies: ${missing_deps[*]}")
      
      if [[ "$action" == "install_arch" ]]; then
        if kitty -1 sudo pacman -S "${missing_deps[*]}"; then
          notify-send 'Wallpaper switcher' 'Dependencies installed! Try again!' -a "Wallpaper switcher"
          return 0
        fi
      fi
    fi
    
    return 1
  fi
  
  return 0
}

# 杀死现有的 mpvpaper 进程
kill_existing_mpvpaper() {
  pkill -f -9 mpvpaper 2>/dev/null || true
  log_debug "清理现有 mpvpaper 进程"
}

# 创建视频恢复脚本
create_restore_script() {
  local video_path="$1"
  ensure_directory "$RESTORE_SCRIPT_DIR"
  
  cat > "$RESTORE_SCRIPT.tmp" <<EOF
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
  log_debug "创建视频恢复脚本: $RESTORE_SCRIPT"
}

# 移除恢复脚本
remove_restore() {
  ensure_directory "$RESTORE_SCRIPT_DIR"
  cat > "$RESTORE_SCRIPT.tmp" <<EOF
#!/bin/bash
# The content of this script will be generated by switchwall_1.sh - Don't modify it by yourself.
EOF
  mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
  log_debug "移除恢复脚本"
}

# =============================================================================
# 主题处理函数
# =============================================================================

# 处理 KDE Material You 颜色
handle_kde_material_you_colors() {
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    local enable_qt_apps
    enable_qt_apps=$(jq -r '.appearance.wallpaperTheming.enableQtApps' "$SHELL_CONFIG_FILE" 2>/dev/null)
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
    "$XDG_CONFIG_HOME/matugen/templates/kde/kde-material-you-colors-wrapper.sh" --scheme-variant "$kde_scheme_variant" &
    log_debug "应用 KDE Material You 颜色: $kde_scheme_variant"
  fi
}

# 预处理
pre_process() {
  local mode_flag="$1"
  
  # 设置 GNOME 颜色方案
  if [[ "$mode_flag" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
  elif [[ "$mode_flag" == "light" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true
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
  log_debug "后处理完成: ${screen_width}x${screen_height}, $wallpaper_path"
}

# =============================================================================
# 主要处理函数
# =============================================================================

# 检查并提示放大
check_and_prompt_upscale() {
  local img="$1"
  local screen_dims
  screen_dims=$(get_screen_dimensions)
  local min_width_desired=$(echo "$screen_dims" | cut -d' ' -f1)
  local min_height_desired=$(echo "$screen_dims" | cut -d' ' -f2)
  
  # 处理图片并缓存
  local cached_path
  cached_path=$(process_and_cache_image "$img")
  
  # 发送通知
  if command_exists notify-send; then
    notify-send "壁纸处理完成" "原图: $img\n缓存: $cached_path\n目标尺寸: ${min_width_desired}x${min_height_desired}" -a "Wallpaper switcher"
  fi
  
  echo "$cached_path"
}

# 检测图片配色方案类型
detect_scheme_type_from_image() {
  local img="$1"
  if [[ -f "$SCRIPT_DIR/scheme_for_image.py" ]]; then
    "$SCRIPT_DIR/scheme_for_image.py" "$img" 2>/dev/null | tr -d '\n'
  else
    echo "auto"
  fi
}

# 主要切换函数
switch() {
  local imgpath="$1"
  local mode_flag="$2"
  local type_flag="$3"
  local color_flag="$4"
  local color="$5"
  
  # 获取屏幕信息
  local scale screenx screeny screensizey
  read scale screenx screeny screensizey < <(hyprctl monitors -j | jq '.[] | select(.focused) | .scale, .x, .y, .height' | xargs)
  
  # 计算光标位置
  local cursorposx cursorposy cursorposy_inverted
  cursorposx=$(hyprctl cursorpos -j | jq '.x' 2>/dev/null) || cursorposx=960
  cursorposx=$(bc <<<"scale=0; ($cursorposx - $screenx) * $scale / 1" 2>/dev/null || echo "960")
  cursorposy=$(hyprctl cursorpos -j | jq '.y' 2>/dev/null) || cursorposy=540
  cursorposy=$(bc <<<"scale=0; ($cursorposy - $screeny) * $scale / 1" 2>/dev/null || echo "540")
  cursorposy_inverted=$((screensizey - cursorposy))
  
  if [[ "$color_flag" == "1" ]]; then
    # 颜色模式
    local matugen_args=(color hex "$color")
    local generate_colors_material_args=(--color "$color")
  else
    # 图片模式
    if [[ -z "$imgpath" ]]; then
      log_error "未提供图片路径"
      exit 1
    fi
    
    # 处理图片并获取缓存路径
    local cached_imgpath
    cached_imgpath=$(check_and_prompt_upscale "$imgpath")
    kill_existing_mpvpaper
    
    if is_video "$cached_imgpath"; then
      # 视频处理
      if ! check_video_dependencies; then
        exit 1
      fi
      
      ensure_directory "$THUMBNAIL_DIR"
      
      # 设置壁纸路径
      set_wallpaper_path "$imgpath"
      
      # 设置视频壁纸
      local video_path="$cached_imgpath"
      local monitors
      monitors=$(hyprctl monitors -j | jq -r '.[] | .name')
      
      for monitor in $monitors; do
        mpvpaper -o "$VIDEO_OPTS" "$monitor" "$video_path" &
        sleep 0.1
      done
      
      # 提取第一帧用于颜色生成
      local thumbnail="$THUMBNAIL_DIR/$(basename "$cached_imgpath").jpg"
      if ffmpeg -y -i "$cached_imgpath" -vframes 1 "$thumbnail" 2>/dev/null; then
        set_thumbnail_path "$thumbnail"
        if [[ -f "$thumbnail" ]]; then
          local matugen_args=(image "$thumbnail")
          local generate_colors_material_args=(--path "$thumbnail")
          create_restore_script "$video_path"
        else
          log_error "无法创建缩略图"
          remove_restore
          exit 1
        fi
      else
        log_error "无法提取视频帧"
        remove_restore
        exit 1
      fi
    else
      # 图片处理
      local matugen_args=(image "$cached_imgpath")
      local generate_colors_material_args=(--path "$cached_imgpath")
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
  
  # 检查是否启用应用和shell主题
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    local enable_apps_shell
    enable_apps_shell=$(jq -r '.appearance.wallpaperTheming.enableAppsAndShell' "$SHELL_CONFIG_FILE" 2>/dev/null)
    if [[ "$enable_apps_shell" == "false" ]]; then
      log_info "应用和shell主题已禁用，跳过matugen和颜色生成"
      return
    fi
  fi
  
  # 执行主题生成
  if command_exists matugen; then
    matugen "${matugen_args[@]}"
  else
    log_warn "未找到 matugen 命令"
  fi
  
  # 生成颜色
  if [[ -n "$ILLOGICAL_IMPULSE_VIRTUAL_ENV" && -f "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate" ]]; then
    source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate"
    if [[ -f "$SCRIPT_DIR/generate_colors_material.py" ]]; then
      python3 "$SCRIPT_DIR/generate_colors_material.py" "${generate_colors_material_args[@]}" \
        > "$STATE_DIR/user/generated/material_colors.scss"
      
      if [[ -f "$SCRIPT_DIR/applycolor.sh" ]]; then
        "$SCRIPT_DIR/applycolor.sh"
      fi
    fi
    deactivate
  else
    log_warn "未找到虚拟环境或Python脚本"
  fi
  
  # 后处理
  local screen_dims
  screen_dims=$(get_screen_dimensions)
  local max_width_desired=$(echo "$screen_dims" | cut -d' ' -f1)
  local max_height_desired=$(echo "$screen_dims" | cut -d' ' -f2)
  post_process "$max_width_desired" "$max_height_desired" "$cached_imgpath"
}

# =============================================================================
# 命令行参数处理
# =============================================================================

# 显示帮助信息
show_help() {
  cat << EOF
SwitchWall v1.0 - 智能壁纸切换和主题应用脚本

用法: $0 [选项] [图片路径]

选项:
  --mode <mode>          设置主题模式 (dark/light)
  --type <type>          设置配色方案类型
  --color                使用颜色选择器
  --image <path>         指定图片路径
  --noswitch             使用当前壁纸，不切换
  --show-current         显示当前壁纸路径
  --clear-temp           清除临时文件
  --show-cache           显示缓存文件信息
  --fast                 启用快速处理模式
  --debug                启用调试模式
  -h, --help             显示此帮助信息

配色方案类型:
  scheme-content, scheme-expressive, scheme-fidelity,
  scheme-fruit-salad, scheme-monochrome, scheme-neutral,
  scheme-rainbow, scheme-tonal-spot, auto

环境变量:
  FAST_PROCESSING=true   启用快速图片处理
  ENABLE_DEBUG=true      启用调试输出

示例:
  $0                                    # 交互式选择壁纸
  $0 --image /path/to/image.jpg        # 指定图片
  $0 --color                           # 使用颜色选择器
  $0 --mode dark --type scheme-tonal-spot
  FAST_PROCESSING=true $0              # 快速处理模式

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
    local files
    files=$(find "$SWITCHWALL_CACHE_DIR" -type f 2>/dev/null | wc -l)
    echo "缓存文件数量: $files"
    
    if [[ $files -gt 0 ]]; then
      echo "缓存文件列表:"
      find "$SWITCHWALL_CACHE_DIR" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | while read -r timestamp filepath; do
        local filename=$(basename "$filepath")
        local date=$(date -d "@${timestamp%.*}" '+%Y-%m-%d %H:%M:%S')
        echo "  - $filename (创建时间: $date)"
        
        if command_exists identify; then
          local size
          size=$(identify -format "%wx%h" "$filepath" 2>/dev/null)
          echo "    尺寸: $size"
        fi
      done
    else
      echo "缓存目录为空"
    fi
  else
    echo "缓存目录不存在"
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
  
  # 解析命令行参数
  while [[ $# -gt 0 ]]; do
    case "$1" in
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
            log_error "未找到 hyprpicker 命令"
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
        # 优先从临时文件读取缓存路径，如果没有则从配置文件读取原图路径
        imgpath=$(get_wallpaper_path_from_temp)
        if [[ -z "$imgpath" ]]; then
          imgpath=$(jq -r '.background.wallpaperPath' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "")
        fi
        # 如果从配置文件读取到原图路径，检查是否有对应的缓存文件
        if [[ -n "$imgpath" && -f "$imgpath" ]]; then
          local cached_path
          cached_path=$(get_cache_path "$imgpath")
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
      --fast)
        FAST_PROCESSING="true"
        shift
        ;;
      --debug)
        ENABLE_DEBUG="true"
        shift
        ;;
      -h|--help)
        show_help
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
  
  # 如果没有设置 type_flag，从配置文件获取
  if [[ -z "$type_flag" ]]; then
    type_flag=$(get_type_from_config)
  fi
  
  # 验证 type_flag
  if ! validate_scheme_type "$type_flag"; then
    log_warn "无效的配色方案类型 '$type_flag'，使用默认值 'auto'"
    type_flag="auto"
  fi
  
  # 如果没有设置 imgpath 且不是颜色模式，交互式选择图片
  if [[ -z "$imgpath" && -z "$color_flag" && -z "$noswitch_flag" ]]; then
    log_info "启动交互式图片选择..."
    
    local new_imgpath
    if new_imgpath=$(select_new_image); then
      log_debug "选择的图片路径: '$new_imgpath'"
      
      if [[ -n "$new_imgpath" && -f "$new_imgpath" ]]; then
        local new_filename
        new_filename=$(basename "$new_imgpath")
        log_debug "图片文件名: $new_filename"
        
        # 获取临时文件中的路径
        local temp_imgpath
        temp_imgpath=$(get_wallpaper_path_from_temp)
        log_debug "临时文件中的路径: $temp_imgpath"
        
        if [[ -n "$temp_imgpath" && -f "$temp_imgpath" ]]; then
          local temp_filename
          temp_filename=$(basename "$temp_imgpath")
          
          # 比较文件名
          if [[ "$new_filename" == "$temp_filename" ]]; then
            # 文件名相同，检查缓存
            local cached_imgpath="$SWITCHWALL_CACHE_DIR/$new_filename"
            if [[ -f "$cached_imgpath" ]]; then
              imgpath="$cached_imgpath"
              log_info "文件名相同，使用缓存中的壁纸: $cached_imgpath"
            else
              imgpath="$new_imgpath"
              log_info "文件名相同但缓存中无同名文件，使用新选择的壁纸: $new_imgpath"
              save_wallpaper_path_to_temp "$new_imgpath"
            fi
          else
            # 文件名不同，使用新文件
            imgpath="$new_imgpath"
            log_info "使用新选择的壁纸: $new_imgpath"
            save_wallpaper_path_to_temp "$new_imgpath"
          fi
        else
          # 临时文件不存在，使用新文件
          imgpath="$new_imgpath"
          log_info "临时文件不存在，使用新选择的壁纸: $new_imgpath"
          save_wallpaper_path_to_temp "$new_imgpath"
        fi
      else
        log_error "选择的图片无效: $new_imgpath"
        exit 1
      fi
    else
      log_error "图片选择失败"
      exit 1
    fi
  fi
  
  # 如果 type_flag 是 'auto'，从图片检测配色方案类型
  if [[ "$type_flag" == "auto" ]]; then
    if [[ -n "$imgpath" && -f "$imgpath" ]]; then
      local detected_type
      detected_type=$(detect_scheme_type_from_image "$imgpath")
      
      if validate_scheme_type "$detected_type" && [[ "$detected_type" != "auto" ]]; then
        type_flag="$detected_type"
        log_debug "自动检测配色方案类型: $type_flag"
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
  log_error "未找到 hyprctl 命令，此脚本需要 Hyprland"
  exit 1
fi

if ! command_exists jq; then
  log_error "未找到 jq 命令，请安装 jq"
  exit 1
fi

# 执行主函数
main "$@" 