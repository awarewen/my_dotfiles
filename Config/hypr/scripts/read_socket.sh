#!/usr/bin/env bash

# Read hyprland socket
# NIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

Socket_Case (){
  case $1 in
    fullscreen) stop_switch_wallpaper
}

## 循环读取

socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do Socket_Case "$line"; done
