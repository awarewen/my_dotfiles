#!/bin/bash

# 设置输入法环境变量
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# 强制使用 X11 后端
export QT_QPA_PLATFORM=xcb
export GDK_BACKEND=x11

# 启动 Cursor
exec /home/awarewen/Applications/cursor-bin_28fab4e9f16f9024a8aecb624f85f5fe.AppImage "$@" 