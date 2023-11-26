#!/usr/bin/env bash

# Read hyprland socket
# NIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# init
wallpaper_switch_stop=0
PID_FILE=/tmp/read_socket_pid
trap '[ ! -f /tmp/wallpaper_script_pid ] || kill -STOP $(cat /tmp/wallpaper_script_pid)' SIGUSR1
trap '[ ! -f /tmp/wallpaper_script_pid ] || kill -CONT $(cat /tmp/wallpaper_script_pid)' SIGUSR2
SATE=0

if [ ! -f $PID_FILE ]; then # PID_FILE is not exist
  command touch $PID_FILE
  echo $$ > $PID_FILE
fi

Socket_Case (){
  case $1 in
    "fullscreen>>1") # Stop
        ((wallpaper_switch_stop++))
        if [ $wallpaper_switch_stop -gt 0 ]; then
           [ ! -f /tmp/wallpaper_script_pid ] || kill -STOP $(cat /tmp/wallpaper_script_pid)
           SATE=1
        fi
      ;;

    "fullscreen>>0")
        [ ! $wallpaper_switch_stop -ge 1 ] || ((wallpaper_switch_stop--))
        if [ $wallpaper_switch_stop -eq 0 ]; then
           [ ! -f /tmp/wallpaper_script_pid ] || kill -CONT $(cat /tmp/wallpaper_script_pid)
           SATE=2
        fi
      ;;

  esac
}

socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock \
  | while read -r line; do
        Socket_Case "$line"
    done
