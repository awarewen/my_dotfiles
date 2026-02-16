#!/usr/bin/env bash

QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
MATUGEN_DIR="$XDG_CONFIG_HOME/matugen"
terminalscheme="$SCRIPT_DIR/terminal/scheme-base.json"

# 临时文件路径定义
TEMP_WALLPAPER_FILE="$HOME/.cache/switchwall/wallpaper_path.tmp"

# 缓存目录定义
SWITCHWALL_CACHE_DIR="$HOME/.cache/switchwall"
CACHED_WALLPAPER_FILE="$SWITCHWALL_CACHE_DIR/wallpaper"

# 确保缓存目录存在
ensure_cache_dir() {
  mkdir -p "$SWITCHWALL_CACHE_DIR"
}

# 处理图片：复制到缓存目录并调整尺寸
process_and_cache_image() {
  local source_path="$1"
  local filename=$(basename "$source_path")
  local target_path="$SWITCHWALL_CACHE_DIR/$filename"
  
  # 确保缓存目录存在
  ensure_cache_dir
  
  # 获取屏幕尺寸信息
  local max_width=$(hyprctl monitors -j | jq '([.[].width] | max)' | xargs)
  local max_height=$(hyprctl monitors -j | jq '([.[].height] | max)' | xargs)
  
  # 获取原图尺寸
  local img_width img_height
  if is_video "$source_path"; then
    # 视频文件直接复制，不调整尺寸
    cp "$source_path" "$target_path"
    return 0
  else
    img_width=$(identify -format "%w" "$source_path" 2>/dev/null)
    img_height=$(identify -format "%h" "$source_path" 2>/dev/null)
  fi
  
  # 检查是否需要调整尺寸
  if [[ "$img_width" -lt "$max_width" || "$img_height" -lt "$max_height" ]]; then
    # 计算调整后的尺寸，保持宽高比
    local scale_w=$(echo "scale=2; $max_width / $img_width" | bc)
    local scale_h=$(echo "scale=2; $max_height / $img_height" | bc)
    local scale=$(echo "scale=2; if ($scale_w > $scale_h) $scale_w else $scale_h" | bc)
    
    local new_width=$(echo "scale=0; $img_width * $scale / 1" | bc)
    local new_height=$(echo "scale=0; $img_height * $scale / 1" | bc)
    
    # 使用magick命令调整尺寸并复制到缓存
    if command -v magick &>/dev/null; then
      # 使用更安全的magick命令参数，确保输出格式正确
      magick "$source_path" -resize "${new_width}x${new_height}^" -gravity center -extent "${max_width}x${max_height}" -quality 95 "$target_path"
      # 验证生成的图片是否有效
      if [ -f "$target_path" ] && magick identify "$target_path" &>/dev/null; then
        echo "图片已调整尺寸并缓存: ${img_width}x${img_height} -> ${max_width}x${max_height}" >&2
      else
        echo "警告: magick处理失败，尝试使用备用方法" >&2
        # 备用方法：使用更简单的resize
        magick "$source_path" -resize "${max_width}x${max_height}^" -gravity center -extent "${max_width}x${max_height}" "$target_path"
        if [ ! -f "$target_path" ] || ! magick identify "$target_path" &>/dev/null; then
          echo "警告: magick备用方法也失败，直接复制原图" >&2
          cp "$source_path" "$target_path"
        fi
      fi
    else
      # 如果没有magick命令，直接复制原图
      cp "$source_path" "$target_path"
      echo "警告: 未找到magick命令，直接复制原图" >&2
    fi
  else
    # 尺寸足够，直接复制
    cp "$source_path" "$target_path"
    echo "图片尺寸足够，直接缓存: ${img_width}x${img_height}" >&2
  fi
  
  # 返回缓存文件的路径
  echo "$target_path"
}

# 保存壁纸路径到临时文件
save_wallpaper_path_to_temp() {
  local path="$1"
  if [ -n "$path" ]; then
    mkdir -p "$(dirname "$TEMP_WALLPAPER_FILE")"
    echo "$path" > "$TEMP_WALLPAPER_FILE"
  fi
}

# 保存缓存壁纸路径到临时文件
save_cached_wallpaper_path_to_temp() {
  local original_path="$1"
  local filename=$(basename "$original_path")
  local cached_path="$SWITCHWALL_CACHE_DIR/$filename"
  if [ -n "$original_path" ] && [ -f "$cached_path" ]; then
    mkdir -p "$(dirname "$TEMP_WALLPAPER_FILE")"
    echo "$cached_path" > "$TEMP_WALLPAPER_FILE"
  fi
}

# 从临时文件读取壁纸路径
get_wallpaper_path_from_temp() {
  if [ -f "$TEMP_WALLPAPER_FILE" ]; then
    cat "$TEMP_WALLPAPER_FILE"
  else
    echo ""
  fi
}

# 删除临时文件
remove_temp_wallpaper_file() {
  if [ -f "$TEMP_WALLPAPER_FILE" ]; then
    rm "$TEMP_WALLPAPER_FILE"
  fi
}

handle_kde_material_you_colors() {
  # Check if Qt app theming is enabled in config
  if [ -f "$SHELL_CONFIG_FILE" ]; then
    enable_qt_apps=$(jq -r '.appearance.wallpaperTheming.enableQtApps' "$SHELL_CONFIG_FILE")
    if [ "$enable_qt_apps" == "false" ]; then
      return
    fi
  fi

  # Map $type_flag to allowed scheme variants for kde-material-you-colors-wrapper.sh
  local kde_scheme_variant=""
  case "$type_flag" in
  scheme-content | scheme-expressive | scheme-fidelity | scheme-fruit-salad | scheme-monochrome | scheme-neutral | scheme-rainbow | scheme-tonal-spot)
    kde_scheme_variant="$type_flag"
    ;;
  *)
    kde_scheme_variant="scheme-tonal-spot" # default
    ;;
  esac
  "$XDG_CONFIG_HOME"/matugen/templates/kde/kde-material-you-colors-wrapper.sh --scheme-variant "$kde_scheme_variant"
}

pre_process() {
  local mode_flag="$1"
  # Set GNOME color-scheme if mode_flag is dark or light
  if [[ "$mode_flag" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
  elif [[ "$mode_flag" == "light" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
  fi

  if [ ! -d "$CACHE_DIR"/user/generated ]; then
    mkdir -p "$CACHE_DIR"/user/generated
  fi
}

post_process() {
  local screen_width="$1"
  local screen_height="$2"
  local wallpaper_path="$3"

  handle_kde_material_you_colors &

  # Determine the largest region on the wallpaper that's sufficiently un-busy to put widgets in
  # if [ ! -f "$MATUGEN_DIR/scripts/least_busy_region.py" ]; then
  #     echo "Error: least_busy_region.py script not found in $MATUGEN_DIR/scripts/"
  # else
  #     "$MATUGEN_DIR/scripts/least_busy_region.py" \
  #         --screen-width "$screen_width" --screen-height "$screen_height" \
  #         --width 300 --height 200 \
  #         "$wallpaper_path" > "$STATE_DIR"/user/generated/wallpaper/least_busy_region.json
  # fi
}

check_and_prompt_upscale() {
  local img="$1"
  min_width_desired="$(hyprctl monitors -j | jq '([.[].width] | max)' | xargs)"   # max monitor width
  min_height_desired="$(hyprctl monitors -j | jq '([.[].height] | max)' | xargs)" # max monitor height
  
  # 处理图片并缓存
  local cached_path=$(process_and_cache_image "$img")
  
  # 发送通知显示处理结果
  notify-send "壁纸处理完成" "原图: $img\n缓存: $cached_path\n目标尺寸: ${min_width_desired}x${min_height_desired}" -a "Wallpaper switcher"
  
  # 返回缓存文件路径
  echo "$cached_path"
}

CUSTOM_DIR="$XDG_CONFIG_HOME/hypr/custom"
RESTORE_SCRIPT_DIR="$CUSTOM_DIR/scripts"
RESTORE_SCRIPT="$RESTORE_SCRIPT_DIR/__restore_video_wallpaper.sh"
THUMBNAIL_DIR="$RESTORE_SCRIPT_DIR/mpvpaper_thumbnails"
VIDEO_OPTS="no-audio loop hwdec=auto scale=bilinear interpolation=no video-sync=display-resample panscan=1.0 video-scale-x=1.0 video-scale-y=1.0 video-align-x=0.5 video-align-y=0.5 load-scripts=no"

is_video() {
  local extension="${1##*.}"
  [[ "$extension" == "mp4" || "$extension" == "webm" || "$extension" == "mkv" || "$extension" == "avi" || "$extension" == "mov" ]] && return 0 || return 1
}

kill_existing_mpvpaper() {
  pkill -f -9 mpvpaper || true
}

create_restore_script() {
  local video_path=$1
  cat >"$RESTORE_SCRIPT.tmp" <<EOF
#!/bin/bash
# Generated by switchwall.sh - Don't modify it by yourself.
# Time: $(date)

pkill -f -9 mpvpaper

for monitor in \$(hyprctl monitors -j | jq -r '.[] | .name'); do
    mpvpaper -o "$VIDEO_OPTS" "\$monitor" "$video_path" &
    sleep 0.1
done
EOF
  mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
  chmod +x "$RESTORE_SCRIPT"
}

remove_restore() {
  cat >"$RESTORE_SCRIPT.tmp" <<EOF
#!/bin/bash
# The content of this script will be generated by switchwall.sh - Don't modify it by yourself.
EOF
  mv "$RESTORE_SCRIPT.tmp" "$RESTORE_SCRIPT"
}

set_wallpaper_path() {
  local path="$1"
  if [ -f "$SHELL_CONFIG_FILE" ]; then
    jq --arg path "$path" '.background.wallpaperPath = $path' "$SHELL_CONFIG_FILE" >"$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
  fi
  # 同时保存缓存路径到临时文件
  save_cached_wallpaper_path_to_temp "$path"
}

set_thumbnail_path() {
  local path="$1"
  if [ -f "$SHELL_CONFIG_FILE" ]; then
    jq --arg path "$path" '.background.thumbnailPath = $path' "$SHELL_CONFIG_FILE" >"$SHELL_CONFIG_FILE.tmp" && mv "$SHELL_CONFIG_FILE.tmp" "$SHELL_CONFIG_FILE"
  fi
}

switch() {
  imgpath="$1"
  mode_flag="$2"
  type_flag="$3"
  color_flag="$4"
  color="$5"
  read scale screenx screeny screensizey < <(hyprctl monitors -j | jq '.[] | select(.focused) | .scale, .x, .y, .height' | xargs)
  cursorposx=$(hyprctl cursorpos -j | jq '.x' 2>/dev/null) || cursorposx=960
  cursorposx=$(bc <<<"scale=0; ($cursorposx - $screenx) * $scale / 1")
  cursorposy=$(hyprctl cursorpos -j | jq '.y' 2>/dev/null) || cursorposy=540
  cursorposy=$(bc <<<"scale=0; ($cursorposy - $screeny) * $scale / 1")
  cursorposy_inverted=$((screensizey - cursorposy))

  if [[ "$color_flag" == "1" ]]; then
    matugen_args=(color hex "$color")
    generate_colors_material_args=(--color "$color")
  else
    if [[ -z "$imgpath" ]]; then
      echo 'Aborted'
      exit 0
    fi

    # 处理图片并获取缓存路径
    cached_imgpath=$(check_and_prompt_upscale "$imgpath")
    kill_existing_mpvpaper

    if is_video "$cached_imgpath"; then
      mkdir -p "$THUMBNAIL_DIR"

      missing_deps=()
      if ! command -v mpvpaper &>/dev/null; then
        missing_deps+=("mpvpaper")
      fi
      if ! command -v ffmpeg &>/dev/null; then
        missing_deps+=("ffmpeg")
      fi
      if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Missing deps: ${missing_deps[*]}"
        echo "Arch: sudo pacman -S ${missing_deps[*]}"
        action=$(notify-send \
          -a "Wallpaper switcher" \
          -c "im.error" \
          -A "install_arch=Install (Arch)" \
          "Can't switch to video wallpaper" \
          "Missing dependencies: ${missing_deps[*]}")
        if [[ "$action" == "install_arch" ]]; then
          kitty -1 sudo pacman -S "${missing_deps[*]}"
          if command -v mpvpaper &>/dev/null && command -v ffmpeg &>/dev/null; then
            notify-send 'Wallpaper switcher' 'Alright, try again!' -a "Wallpaper switcher"
          fi
        fi
        exit 0
      fi

      # Set wallpaper path (保存原图路径到配置)
      set_wallpaper_path "$imgpath"

      # Set video wallpaper (使用缓存文件)
      local video_path="$cached_imgpath"
      monitors=$(hyprctl monitors -j | jq -r '.[] | .name')
      for monitor in $monitors; do
        mpvpaper -o "$VIDEO_OPTS" "$monitor" "$video_path" &
        sleep 0.1
      done

      # Extract first frame for color generation
      thumbnail="$THUMBNAIL_DIR/$(basename "$cached_imgpath").jpg"
      ffmpeg -y -i "$cached_imgpath" -vframes 1 "$thumbnail" 2>/dev/null

      # Set thumbnail path
      set_thumbnail_path "$thumbnail"

      if [ -f "$thumbnail" ]; then
        matugen_args=(image "$thumbnail")
        generate_colors_material_args=(--path "$thumbnail")
        create_restore_script "$video_path"
      else
        echo "Cannot create image to colorgen"
        remove_restore
        exit 1
      fi
    else
      matugen_args=(image "$cached_imgpath")
      generate_colors_material_args=(--path "$cached_imgpath")
      # Update wallpaper path in config (保存原图路径)
      set_wallpaper_path "$imgpath"
      remove_restore
    fi
  fi

  # Determine mode if not set
  if [[ -z "$mode_flag" ]]; then
    current_mode=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")
    if [[ "$current_mode" == "prefer-dark" ]]; then
      mode_flag="dark"
    else
      mode_flag="light"
    fi
  fi

  [[ -n "$mode_flag" ]] && matugen_args+=(--mode "$mode_flag") && generate_colors_material_args+=(--mode "$mode_flag")
  [[ -n "$type_flag" ]] && matugen_args+=(--type "$type_flag") && generate_colors_material_args+=(--scheme "$type_flag")
  generate_colors_material_args+=(--termscheme "$terminalscheme" --blend_bg_fg)
  generate_colors_material_args+=(--cache "$STATE_DIR/user/generated/color.txt")

  pre_process "$mode_flag"

  # Check if app and shell theming is enabled in config
  if [ -f "$SHELL_CONFIG_FILE" ]; then
    enable_apps_shell=$(jq -r '.appearance.wallpaperTheming.enableAppsAndShell' "$SHELL_CONFIG_FILE")
    if [ "$enable_apps_shell" == "false" ]; then
      echo "App and shell theming disabled, skipping matugen and color generation"
      return
    fi
  fi

  matugen "${matugen_args[@]}"
  source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate"
  python3 "$SCRIPT_DIR/generate_colors_material.py" "${generate_colors_material_args[@]}" \
    >"$STATE_DIR"/user/generated/material_colors.scss
  "$SCRIPT_DIR"/applycolor.sh
  deactivate

  # Pass screen width, height, and wallpaper path to post_process
  max_width_desired="$(hyprctl monitors -j | jq '([.[].width] | min)' | xargs)"
  max_height_desired="$(hyprctl monitors -j | jq '([.[].height] | min)' | xargs)"
  post_process "$max_width_desired" "$max_height_desired" "$cached_imgpath"
}

main() {
  imgpath=""
  mode_flag=""
  type_flag=""
  color_flag=""
  color=""
  noswitch_flag=""

  get_type_from_config() {
    jq -r '.appearance.palette.type' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "auto"
  }

  detect_scheme_type_from_image() {
    local img="$1"
    "$SCRIPT_DIR"/scheme_for_image.py "$img" 2>/dev/null | tr -d '\n'
  }

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
        color=$(hyprpicker --no-fancy)
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
      if [ -z "$imgpath" ]; then
        imgpath=$(jq -r '.background.wallpaperPath' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "")
      fi
      # 如果从配置文件读取到原图路径，检查是否有对应的缓存文件
      if [ -n "$imgpath" ] && [ -f "$imgpath" ]; then
        local filename=$(basename "$imgpath")
        local cached_path="$SWITCHWALL_CACHE_DIR/$filename"
        if [ -f "$cached_path" ]; then
          imgpath="$cached_path"
        fi
      fi
      shift
      ;;
    --show-current)
      current_path=$(get_wallpaper_path_from_temp)
      if [ -n "$current_path" ]; then
        echo "当前临时文件中的壁纸路径: $current_path"
        if [ -f "$current_path" ]; then
          echo "文件存在: 是"
        else
          echo "文件存在: 否"
        fi
      else
        echo "临时文件中没有保存的壁纸路径"
      fi
      exit 0
      ;;
    --clear-temp)
      remove_temp_wallpaper_file
      echo "临时文件已清除"
      exit 0
      ;;
    --show-cache)
      if [ -d "$SWITCHWALL_CACHE_DIR" ]; then
        echo "缓存目录: $SWITCHWALL_CACHE_DIR"
        if [ "$(ls -A "$SWITCHWALL_CACHE_DIR" 2>/dev/null)" ]; then
          echo "缓存文件列表:"
          for cached_file in "$SWITCHWALL_CACHE_DIR"/*; do
            if [ -f "$cached_file" ]; then
              echo "  - $(basename "$cached_file")"
              if command -v identify &>/dev/null; then
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

  # If type_flag is not set, get it from config
  if [[ -z "$type_flag" ]]; then
    type_flag="$(get_type_from_config)"
  fi

  # Validate type_flag (allow 'auto' as well)
  allowed_types=(scheme-content scheme-expressive scheme-fidelity scheme-fruit-salad scheme-monochrome scheme-neutral scheme-rainbow scheme-tonal-spot auto)
  valid_type=0
  for t in "${allowed_types[@]}"; do
    if [[ "$type_flag" == "$t" ]]; then
      valid_type=1
      break
    fi
  done
  if [[ $valid_type -eq 0 ]]; then
    echo "[switchwall.sh] Warning: Invalid type '$type_flag', defaulting to 'auto'" >&2
    type_flag="auto"
  fi

  # Only prompt for wallpaper if not using --color and not using --noswitch and no imgpath set
  if [[ -z "$imgpath" && -z "$color_flag" && -z "$noswitch_flag" ]]; then
    # 调用外部程序获取新的文件路径
    cd "$(xdg-user-dir PICTURES)/Wallpapers/showcase" 2>/dev/null || cd "$(xdg-user-dir PICTURES)/Wallpapers" 2>/dev/null || cd "$(xdg-user-dir PICTURES)" || return 1
    new_imgpath="$(vimiv -o %)" # 这里可以替换为你想要的外部程序
    # 清理路径，移除可能的换行符和多余空格
    new_imgpath=$(echo "$new_imgpath" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # 如果是相对路径，转换为绝对路径
    if [[ "$new_imgpath" != /* ]]; then
      new_imgpath="$(pwd)/$new_imgpath"
    fi
    echo "new_imgpath: '$new_imgpath'"
    
    echo "检查 new_imgpath 是否为空: $([ -n "$new_imgpath" ] && echo "不为空" || echo "为空")"
    echo "检查 new_imgpath 文件是否存在: $([ -f "$new_imgpath" ] && echo "存在" || echo "不存在")"
    if [ -n "$new_imgpath" ] && [ -f "$new_imgpath" ]; then
      # 获取新文件的文件名
      new_filename=$(basename "$new_imgpath")
      echo "new_filename: $new_filename"
      
      # 获取临时文件中的路径和文件名
      temp_imgpath=$(get_wallpaper_path_from_temp)
      echo "temp_imgpath: $temp_imgpath"
      if [ -n "$temp_imgpath" ] && [ -f "$temp_imgpath" ]; then
        temp_filename=$(basename "$temp_imgpath")
        # 比较文件名，如果相同则使用缓存中的同名图片，否则使用新文件
        if [ "$new_filename" = "$temp_filename" ]; then
          # 如果文件名相同，检查缓存中是否有同名文件
          cached_imgpath="$SWITCHWALL_CACHE_DIR/$new_filename"
          if [ -f "$cached_imgpath" ]; then
            imgpath="$cached_imgpath"
            echo "文件名相同，使用缓存中的壁纸: $cached_imgpath"
          else
            # 缓存中没有同名文件，使用新选择的文件
            imgpath="$new_imgpath"
            echo "文件名相同但缓存中无同名文件，使用新选择的壁纸: $new_imgpath"
            # 更新临时文件，保存新图片的原始路径
            save_wallpaper_path_to_temp "$new_imgpath"
          fi
        else
          # 文件名不同，使用新选择的文件，并更新临时文件
          imgpath="$new_imgpath"
          echo "使用新选择的壁纸: $new_imgpath"
          # 立即更新临时文件，保存新图片的原始路径
          save_wallpaper_path_to_temp "$new_imgpath"
        fi
      else
        # 临时文件不存在，直接使用新文件
        imgpath="$new_imgpath"
        echo "临时文件不存在，使用新选择的壁纸: $new_imgpath"
        # 更新临时文件，保存新图片的原始路径
        save_wallpaper_path_to_temp "$new_imgpath"
      fi
    else
      # 如果外部程序没有返回有效路径，尝试从配置文件读取
      config_imgpath=$(jq -r '.background.wallpaperPath' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "")
      if [ -n "$config_imgpath" ] && [ -f "$config_imgpath" ]; then
        imgpath="$config_imgpath"
        echo "使用配置文件中的壁纸: $config_imgpath"
      else
        echo "错误: 无法获取有效的壁纸路径"
        return 1
      fi
    fi
  fi

  # If type_flag is 'auto', detect scheme type from image (after imgpath is set)
  if [[ "$type_flag" == "auto" ]]; then
    if [[ -n "$imgpath" && -f "$imgpath" ]]; then
      detected_type="$(detect_scheme_type_from_image "$imgpath")"
      # Only use detected_type if it's valid
      valid_detected=0
      for t in "${allowed_types[@]}"; do
        if [[ "$detected_type" == "$t" && "$detected_type" != "auto" ]]; then
          valid_detected=1
          break
        fi
      done
      if [[ $valid_detected -eq 1 ]]; then
        type_flag="$detected_type"
      else
        echo "[switchwall] Warning: Could not auto-detect a valid scheme, defaulting to 'scheme-tonal-spot'" >&2
        type_flag="scheme-tonal-spot"
      fi
    else
      echo "[switchwall] Warning: No image to auto-detect scheme from, defaulting to 'scheme-tonal-spot'" >&2
      type_flag="scheme-tonal-spot"
    fi
  fi

  switch "$imgpath" "$mode_flag" "$type_flag" "$color_flag" "$color"
}

main "$@"
