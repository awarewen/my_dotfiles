#!/bin/bash

# 设置输入法环境变量（适用于 Wayland）
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Wayland 特定设置
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland

# 确保 fcitx5 正在运行
if ! pgrep -x "fcitx5" > /dev/null; then
    echo "启动 fcitx5..."
    fcitx5 -d
    sleep 2
fi

# 启动 Cursor
exec /home/awarewen/Applications/cursor-bin_28fab4e9f16f9024a8aecb624f85f5fe.AppImage "$@" 