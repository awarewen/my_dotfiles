#!/usr/bin/env bash
# 双屏情况
# 需求： 在插入屏幕时将eww 转移至新屏幕上，在移除屏幕时将eww 移回focused 屏幕
## 暂定 由于目前eww版本对于 wayland 下 的monitor 不支持变量
# 提取 hyprctl monitors 中对应 new_monitor 的 id
# 使用sed 直接修改配置。
# 目前 eww 可以正常启动切换屏幕
# 但是由于脚本一直监听，eww 变成跟随monitor焦点,不符合我的需求

## 后续优化
# grep "monitor" -rl $EWW_CONF_DIR | xargs sed -i "s/:monitor \".*\"/:monitor \"1\"/g"
# 将屏幕列出为数组或者json 然后提取出 focused 屏幕
# 可以支持多块屏幕
# 查看 monitoradd 之后是否有 focused socket

## 当新屏幕接入之后 调用脚本
EWW_CONF_DIR=$HOME/.config/eww

function handle {
  if [[ ${1:0:10} == "monitoradd" ]]; then  # 添加新的显示器
    MONITOR=${1:12:0}                       # 读取新添加显示器名称
    MONITOR_ID=$(hyprctl monitors -j | gojq '.[] | select(.name == $a) | .id ' --arg a $MONITOR -r) # 读取对应名称的id
    grep "monitor" -rl $EWW_CONF_DIR | xargs sed -i "s/:monitor \".*\"/:monitor \"$MONITOR_ID\"/g"  # 修改eww 配置至新添加的显示器屏幕
    hyprctl keyword monitor $MONITOR,addreserved,40,10,10,10                                        # 为eww 留出合适的高度
    killall eww && eww -c $EWW_CONF_DIR daemon && eww -c ~/.config/eww open bar && eww -c ~/.config/eww open bgdecor # 启动 EWW
    MONITOR=$(hyprctl monitors -j | jq '.[] | select(.focused == false) | .name ' -r)               # 读取另一块屏幕
    hyprctl keyword monitor $MONITOR,addreserved,10,10,10,10                                        # 移除 eww 的屏幕回到正常大小

    else if [[ ${1:0:14} == "monitorremoved" ]]; then  # 需要修改
      #MONITOR=$(echo "$1" | awk -F'>>' '{print $2}' | cut -d ',' -f 1)
      MONITOR=${1:16:0}
      MONITOR_ID=$(hyprctl monitors -j | gojq '.[] | select(.name == $a) | .id ' --arg a $MONITOR -r)
      grep "monitor" -rl $EWW_CONF_DIR | xargs sed -i "s/:monitor \".*\"/:monitor \"$MONITOR_ID\"/g"
      hyprctl keyword monitor $MONITOR,addreserved,40,10,10,10
      killall eww && eww -c $EWW_CONF_DIR daemon && eww -c ~/.config/eww open bar && eww -c ~/.config/eww open bgdecor
      hyprctl keyword monitor $MONITOR,addreserved,10,10,10,10
    fi
  fi
}

socat - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
