# 重新配置hyprland 桌面配置环境
- WM: Hyprland
- OS: Archlinux

## 依赖软件列表
- waybar-hyprland-git waybar-mpris-git starship fish (剔出)
```
paru -S hyprland-git  cava  python rustup kitty wofi xdg-desktop-portal-hyprland-git tty-clock-git swaylockd swaylock-effects-git swayidle grim slurp swappy jq dunst wl-clipboard cliphist wl-clip-persist swww-git zsh tmux ranger sddm-git qt5-base qt5-wayland qt6-base qt6-wayland light g4music btop
```
- 重写 hyprland 配置
hyprctl clients : list of windows message

- 完善 hyprland 脚本

## 触屏相关

## 触摸板手势
libinput-gestures
hyprland-touch-gestures

- 触摸屏配置，支持多点触控，手势
xf86-input-mtrack

- xf86-input-wacom 仅支持x11, wayland 下无法对设备进行配置
    [Wayland · linuxwacom/xf86-input-wacom Wiki](https://github.com/linuxwacom/xf86-input-wacom/wiki/Wayland)

-- libinput
[libinput 1.23.0 文档](https://wayland.freedesktop.org/libinput/doc/latest/)

-- 原来的X11 touch.conf 不太适用

### 数位板支持
````
yay -S opentabletdriver-git

systemctl --user enable --now opentabletdriver

disable wacom modules in /etc/modprobe.d/blacklist.conf
````

### touchscreen setting
````
## hyprland.conf
# 将触控笔和触控屏幕两个功能分开设置即可实现不同的旋转
_________________
device:gxtp7380:00-27c6:0113-stylus { ## touch  pen
    transform=0
    output=DSI-1
  }

device:gxtp7380:00-27c6:0113 { ## touch screen
    transform=1
    output=DSI-1
  }
````

###[lisgd](https://git.sr.ht/~mil/lisgd)
[Using Lisgd And I3 On A Convertible Laptop --- 在可转换笔记本电脑上使用Lisgd和i3](https://www.laubersheimer.eu/2021/08/08/using-lisgd-and-i3-on-a-convertible-laptop.html)

- 有一个问题：触控没有旋转过来 [done]

-- lisgd -d /dev/input/event13 -g "1,RL,*,*,R,notify-send next worksapce && hyprctl dispatch movetoworkspace +1 " 右往左滑动下一个工作区

-- 


Lisgd（libinput 合成手势守护进程）允许您基于 libinput 触摸事件绑定手势以运行要执行的特定命令。
例如，用一根手指从左向右拖动可以执行特定命令，例如启动终端。
定向 L-R、R-L、U-D 和 D-U 手势以及诊断 LD-RU、RD-LU、UR-DL、UL-DR 手势支持 1 到 N 个手指。
- 配置文件,可以通过两种方式进行配置：
1.复制示例配置文件
2. 创建配置文件使用flags的形式配置

- 基于命令行的运行方式
···

    -d [devicenodepath]: Defines the dev filesystem device to monitor


    -d : [TR] top to right,
    -d [设备节点路径]：定义要监视的开发文件系统设备
        Example: lisgd -d /dev/input/input1 例： lisgd -d /dev/input/input1
    -g [nfingers,gesture,edge,distance,actmode,command]: Allows you to bind a gesture wherein nfingers is an integer, gesture is one of {LR,RL,DU,UD,DLUR,URDL,ULDR,DLUR}, edge is one of * (any), N (none), L (left), R (right), T (top), B (bottom), TL (top left), TR (top right), BL (bottom left), BR (bottom right) and distance is one of * (any), S (short), M (medium), L (large). actmode is R (release) for normal mode and P (pressed) for pressed mode (but this field may be omitted entirely for backward compatibility), command is the shell command to be executed. The -g option can be used multiple times to bind multiple gestures.
    -g [nfingers，gesture，edge，distance，actmode，command]：允许您绑定手势，其中nfingers是一个整数，手势是{LR，RL，DU，UD，DLUR，URDL，ULDR，DLUR}之一，边缘是*（任意），N（无），L（左），R（右），T（上），B（下），TL（左上），TR（右上），BL（左下），BR（右下），距离是*（任意）之一， S（短），M（中），L（大）。actmode 是正常模式的 R（释放），按下模式是 P（按下）（但为了向后兼容，可以完全省略此字段），命令是要执行的 shell 命令。-g 选项可以多次用于绑定多个手势。
        Single Gesture Example: lisgd -g "1,LR,*,*,R,notify-send swiped lr"
        单手势示例： lisgd -g "1,LR,*,*,R,notify-send swiped lr"
        Multiple Gestures Example: lisgd -g "1,LR,*,*,R,notify-send swiped lr" -g "1,RL,R,*,R,notify-send swiped rl from right edge"
        多个手势示例： lisgd -g "1,LR,*,*,R,notify-send swiped lr" -g "1,RL,R,*,R,notify-send swiped rl from right edge"
    -m [timeoutms]: Number of milliseconds gestures must be performed within to be registered. After the timeoutms value; the gesture won't be registered.
    -m [超时]：必须在内执行毫秒数手势才能注册。超时值之后;不会注册该手势。
        Example: lisgd -m 1200 例： lisgd -m 1200
    -o [orientation]: Number of 90-degree rotations to translate gestures by. Can be set to 0-3. For example using 1; a L-R gesture would become a U-D gesture. Meant to be used for screen-rotation.
    -o [方向]：用于平移手势的 90 度旋转次数。可以设置为 0-3。例如，使用 1;L-R 手势将变为 U-D 手势。用于屏幕旋转。
        Example lisgd -o 1 例 lisgd -o 1
    -r [degrees]: Number of degrees offset each 45-degree interval may still be recognized within. Maximum value is 45. Default value is 15. E.g. U-D is a 180 degree gesture but with 15 degrees of leniency will be recognized between 165-195 degrees.
    -r [度]：每个 45 度间隔的偏移度数仍可在其中识别。最大值为 45。默认值为 15。例如，U-D 是 180 度的手势，但 15 度宽大处理将在 165-195 度之间被识别。
        Example: lisgd -r 20 例： lisgd -r 20
    -t [threshold_units]: Threshold in libinput units (pixels) after which a gesture registers. Defaults to 125.
    -t [threshold_units]：以 libinput 单位（像素）为单位的阈值，手势在此之后注册。默认值为 125。
        Example: lisgd -t 125 例： lisgd -t 125
    -T [threshold_units]: Threshold in libinput units (pixels) after which a gesture registers for 'pressed' gestures where fingers are not lifted. Defaults to 60.
    -T [threshold_units]：以 libinput 单位（像素）为单位的阈值，之后手势将注册手指未抬起的“按下”手势。默认值为 60。
        Example: lisgd -t 60 例： lisgd -t 60
    -w [screenwidth]: Width of screen used for edge-based gestures. Use in conjunction with -h. If unset dynamic X/Wayland screen geometry detection is used.
    -w [屏幕宽度]：用于基于边缘的手势的屏幕宽度。与 -h 结合使用。如果使用未设置的动态X/Wayland屏幕几何检测。
        Example: lisgd -w 600 例： lisgd -w 600
    -h [screenheight]: Height of screen used for edge-based gestures. Use in conjunction with -w. If unset dynamic X/Wayland screen geometry detection is used.
    -h [屏幕高度]：用于基于边缘的手势的屏幕高度。与 -w 结合使用。如果使用未设置的动态X/Wayland屏幕几何检测。
        Example: lisgd -h 500 例： lisgd -h 500
    -v: Verbose mode, useful for debugging
    -v：详细模式，对调试很有用
        Example: lisgd -v 例： lisgd -v

···

- 找到对应event
创建 `/etc/udev/rules.d/99-lisgd-device.rules` - `ENV{ID_INPUT_TOUCHSCREEN}=="1", MODE:="0666" GROUP="USERNAME", SYMLINK+="input/touchscreen"` [未测试]

### 锁屏禁止触屏,仅通过键盘按键点亮屏幕
 ````
 misc {
  mouse_move_enables_dpms = false ## 关闭禁用鼠标移动唤醒可以一同禁用触控唤醒
  key_press_enables_dpms = true ##dmps为关闭时，只能通过键盘来唤醒屏幕
}
````

- [libinput - ArchWiki](https://wiki.archlinux.org/title/libinput)
libinput 不解释手势 触摸屏 所以这个实用程序只能用于触摸板，不能用于触摸屏。-- (https://github.com/bulletmark/libinput-gestures)

### wvkbd 虚拟键盘 (工作)

````
yay -S wvkbd

wvkbd-mobintl -H 1920 -L 300
````

hyprland-per-window-layout 支持多键盘布局
````
exec-once = hyprland-per-window-layout
````

## GPD pocket 3 自动旋转支持
[iio-hyprland, Listen iio-sensor-proxy and auto change Hyprland output orientation](https://github.com/JeanSchoeller/iio-hyprland/)
- 已经支持触控屏幕自动旋转
````
yay -S iio-hyprland-git

# 添加到hyprland config
exec-once iio-hyprland DSI-1
````
--- `/etc/udev/rules.d/99-goodix-touch.rules`

### 不知道是不是我做了什么更改触控和触控笔之间旋转相差了2的数量级，所以对自动旋转脚本做了点更改
````
# 安装
sudo make install

# 卸载
sudo make uninstall
````

## Clipboard setting
- wl-clipboard: 提供 wayland 剪贴板支持
    - exec-once
        `exec-once = wl-paste --type text --watch cliphist store   #Stores only text data`
        `exec-once = wl-paste --type image --watch cliphist store  #Stores only image data`

- cliphist: 支持文本和图片的剪贴板包装应用
- - clipboard store show whith wofi
    - keybind
        `bind = SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy`

- wl-clip-persist: 长时间保存剪贴板数据
    - exec-once
        `exec-once = wl-clip-persist --clipboard both              # Use Regular and Primary clipboard,long :w`

## Screenshot
- grim: Grab images from a Wayland compositor.
- slurp: Select a region in a Wayland compositor and print it to the standard output
- [swappy](https://github.com/jtheoof/swappy): jtheoof/swappy：Wayland原生快照编辑工具，灵感来自macOS上的Snappy
```` '$HOME/.config/swappy/config'
[Default]
save_dir=$HOME/Desktop
save_filename_format=swappy-%Y%m%d-%H%M%S.png
show_panel=false
line_size=5
text_size=20
text_font=sans-serif
paint_mode=brush
early_exit=false
fill_shape=false
````

这两个一起配合实现选区截图并保存到剪切板上
    - keybind:
        ````
        bind=SUPER,i,exec,grim -g "$(slurp)" - | wl-copy
        bind=SUPER_ALT,i,exec,grim -g "$(slurp)" - | swappy -f -
        ````
- 配合 `bar` 实现鼠标点击截图功能
````
`~/.config/hypr/scripts/screensort`
_____________________________
#!/usr/bin/bash

grim -g "$(slurp)" - | wl-copy
````

## Lock Screen
- swaylock-effects-git: 锁屏
- swaylockd: swaylock 的启动器，对实用功能进行了包装
- swayidle: 管理空闲事件
配合hyprctl 控制dpms

````
# ~/.config/hypr/scripts/lock
_____________________________
#!/usr//bin/bash

swaylockd --screenshots \
          --grace-no-mouse \
          --grace-no-touch \
          --indicator \
          --clock \
          --inside-wrong-color f38ba8 \
          --ring-wrong-color 11111b \
          --inside-clear-color a6e3a1 \
          --ring-clear-color 11111b \
          --inside-ver-color 89b4fa \
          --ring-ver-color 11111b \
          --text-color  f5c2e7 \
          --indicator-radius 80 \
          --indicator-thickness 5 \
          --effect-blur 10x7 \
          --effect-vignette 0.2:0.2 \
          --ring-color 11111b \
          --key-hl-color f5c2e7 \
          --line-color 313244 \
          --inside-color 0011111b \
          --separator-color 00000000 \
          --indicator-caps-lock \
          --fade-in 0.1 \
          --daemonize

## Dpms ctl ( 2 s )
swayidle -w \
  timeout 2 'if pgrep -x swaylock; then hyprctl dispatch dpms off; else killall swayidle; fi'

````

## 2025-06-28 锁屏程序替换
````
yay -R gtklock swaylock-effects-git
yay -S hyprlock
````
hyprlock 不会自动创建配置 示例配置：[hyprlock](https://github.com/hyprwm/hyprlock/blob/main/assets/example.conf)
`~/.config/hypr/hyprlock.conf`

## 壁纸切换
- 自动切换壁纸
在swww的示例配置中的自动换壁纸脚本
- [swww/swww_randomize.sh at main](https://github.com/Horus645/swww/blob/main/example_scripts/swww_randomize.sh)

## wallpaper and file maneger
- thunar
````
 # @ thunar
   # 支持键盘操作的GUI文件浏览器
   TUMBLER 显示缩略图 -- 默认包不显示缩略图
   # 一些其他文件的缩略图支持
     VEDIO :FFMPEGTHUMBNAILER
     PDF   :POPPLER-GLIB
   # --------------------------
   # 支持移动设备自动挂载需要额外的包
     GVFS
     GVFS-MTP
     GVFS-AFC
````
- ranger + 壁纸切换
````
~/.bscripts/wallset PATH_TO_FILE
#_______________________________
````
- 使用ranger快捷切换壁纸

````
# 添加一个自定义命令
    ～/.config/ranger/commands.py
_________________________________
    class set_wallpaper(Command)
        def execute(self):
            if self.arg(1):
                target_filename = self.rest(1)
            else:
                target_filename = self.fm.thisfile.path
            if not os.path.exists(target_filename):
                self.fm.notify("The given file does not exist!", bad=True)
                return
            self.fm.notify("run command: set_wallpaper " + target_filename)
            self.fm.run('swww img ' + target_filename + ' --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3')
---------------------------------------------------------------------------
    # @ self.fm.thisfile.path 获取当前选定的绝对文件路径
    # @ self.fm.notify 在ranger底栏显示一条信息
    # @ self.fm.run 运行一条命令，这里对wallset进行调用

# 为自定义命令添加键位绑定
    ~/.config/ranger/rc.conf
__________________________
    map tw set_wallpaper
--------------------------
    # @ tw 可以选择一个不冲突的键位绑定
````

## Hight DPI
### FireFox DPI 高分辨率下firefox字体和界面自动放大的问题

1. Open about:config
2. Search `layout.css.devPixelsPerPx` change to `1.5` same to hyprland scale (1.5)

### xwayland 高DPI模糊问题 (缩放问题)
1. - aur/hyprland-hidpi-xprop-git
2. 当'scale'不为1的时候，xwayland应用模糊，wayland不支持非整数缩放
安装 'xorg-xrdb' : `echo 'Xft.dpi:144' | xrdb -merge` (已被缩放dpi为'96'在基础上加上'144')

## 其他程序
- https://github.com/sezanzeb/input-remapper : 鼠标键盘按键重新映射工具
- https://wiki.archlinux.org/title/Xmodmap

## 空闲音频抑制器
- https://github.com/ErikReider/SwayAudioIdleInhibit

## bar (暂时不需要)

## github ssh (Done)


##  不用 DM 启动 hyprland
````
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  # exec wayfire
  # exec sway --unsupported-gpu
  exec Hyprland
  # startx
fi
````

## 音量 背光快捷键控制
````
# Light (未添加通知)
binde=,code:232,exec,light -U 10
binde=,code:233,exec,light -A 10

# Audio (未添加通知), 使用bindle 可以在锁屏的情况下更改音量
bindle=,code:122,exec,amixer set Master 1%-
bindle=,code:123,exec,amixer set Master 1%+
````

## 音量 背光， 进度条
- wob : [GitHub - francma/wob: Wayland 的轻量级叠加卷/背光/进度/任何栏。](https://github.com/francma/wob) 暂时不采用
    - 创建配置文件
````
    ~/.config/wob/wob.ini
    _____________________
    timeout = 1000
    max = 100
    width = 400
    height = 50
    border_offset = 4
    bar_padding = 4
    bar_color = FFFFFF
    margin = 0
    anchor = top center # (top = 1, bottom = 2, left = 4, right = 8 |  top, left, right, bottom, center)
    overflow_mode = 0 # (wrap = 0, nowrap = 1)
    output_mode = whitelist # (whitelist = 0, all = 1, focused = 2)
    #border_color =
    #


    [output.left]
    name = DP-1

    [output.ips]
   name = HDMI-1

    [style.muted]
    background_color = 032cfc
````

- hyprland env config
````
set $WOBSOCK $XDG_RUNTIME_DIR/wob.sock
exec rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | wob
````

- 采用dunst 显示背光，音量调节的进度条

- wlsunset [yes] 支持 wlr-gamma-control-unstable-v1 和 xdg-output-unstable-v1 的 Wayland 合成器的日/夜伽玛调整。
````
wlsunset -l 39.9 -L 116.3
````

## 特殊工作区（暂存区）
````
# Scratchpad
## 将当前窗口发送到特殊工作区
bind = SUPER_ALT,grave,movetoworkspace, special
## 显示和隐藏特殊工作区
bind = SUPER,grave,togglespecialworkspace,

### 将特殊工作区的窗口发送到当前屏幕活动的工作区并平铺
bind = SUPER_ALT, w, movetoworkspace, m+1
bind = SUPER_ALT, w, togglefloating, window

````
## 实用程序
-- Chat
    -- icalingua++ : QQ
    -- telegram

-- ScreenSort
    -- flameshot :  Working bad on wayland, No supper multi-monitor display
    -- kooha : 支持wayland的录屏工具
    -- obs-studio-tytan652: 冲突 libva-vdpau-driver(vdpau 硬件加速){2023-9-23:libmbedcrypto.so.7 缺失 安装mbedtls2 补全依赖}
    -- grimblast: 
    -- wl-recorder :  原始的录屏程序

-- tailscale-git

-- wev :键盘按键码识别

-- vimiv-qt :利用键盘来预览图像的gui图像预览
    -- [Getting Started — vimiv documentation](https://karlch.github.io/vimiv-qt/documentation/getting_started.html)

-- waydroid :完整的安卓

--

## waydroid
[Waydroid | Android in a Linux container --- 机器人 |Linux 容器中的 Android](https://waydro.id/)

## zsh 相关
- zshenv zshrc zshlogin
````
path+=(~/.local/bin;~/.ghcup/bin)

# use bat as man pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
````

## rofi 字体
读取local里面的字体
## TODO
z-shell H-S-MW
添加prtsc截图当前active screen 屏幕 keybind
添加触控笔的按钮

swww 更换壁纸方案2



## btrfs err input/output
- btrfs check --repair 暂时修复


## 冗余配置

- wlsunset 支持 wlr-gamma-control-unstable-v1 和 xdg-output-unstable-v1 的 Wayland 合成器的日/夜伽玛调整。
````
wlsunset -l 39.9 -L 116.3
````


## 参考配置列表 | 解析配置

### [end-4/dots-hyprland at m3ww --- END-4/DOTS-Hyprland at M3WW](https://github.com/end-4/dots-hyprland/tree/m3ww)
1. 依赖列表
````
- python
    * python-pywal              : 🎨 即时生成和更改配色方案。
    * python-desktop-entry-lib  : 用于处理 .desktop 文件的 Python 库
    * python-poetry             : Python 打包,构建,依赖关系管理等等
    * python-build              : 一个简单、正确的 Python 构建前端
    * python-pillow             : 为 Python 解释器添加了图像处理功能。


eww-tray-wayland-git: 支持 tray 的eww   [waybar-hyprland-git] [需要添加layer层配置让eww panal 正常工作]
bc                  : BC 是一种任意精度的数字处理语言
[ blueberry-wayland ](https://github.com/linuxmint/blueberry):一个在 GNOME 之外使用 gnome-蓝牙的包装器gui应用程序。[替换 blueman]
bluez               : 蓝牙的daemons
bluez-utils         : 蓝牙控制工具
boost               : Boost 提供免费的同行评审便携式C++源库。
boost-libs          : Boost libs
coreutils           : GNU 核心实用程序是 GNU 操作系统的基本文件、外壳和文本操作实用程序。
curl                : 下载工具
findutils           : GNU 查找实用程序是 GNU 操作系统的基本目录搜索实用程序。
fish                : fish shell [only zsh]
fuzzel              : 基于wlroots的Wayland合成器的应用程序启动器，类似于rofi的“drun”模式。[rofi wofi] [passwd 补全]
fzf                 : fzf
gawk                : gun 版本awk, awk 实用程序解释一种特殊用途的编程语言，只需几行代码即可处理简单的数据重新格式化作业。
gnome-control-center: GNOME的主界面，用于配置桌面的各个方面。
ibus                : 输入法 [fcitx5]
imagemagick         : 图片处理
libqalculate        : 是一个多用途的跨平台桌面计算器。
light               : 亮度控制
networkmanager
network-manager-applet
nlohmann-json       : 适用于现代C++的 JSON库
pavucontrol         : 音量控制界面          [替换 pavucontrol-qt]
plasma-browser-integration  : plasma 浏览器集成 需要浏览器插件
playerctl           : 播放器控制
procps              : 用于浏览 procfs 的命令行和全屏实用程序，
ripgrep             : ripgrep 是一个面向行的搜索工具，它递归地搜索当前目录以查找正则表达式模式。
socat               : SOCAT是用于在两个独立数据通道之间进行双向数据传输的中继。这些数据通道中的每一个都可以是文件，管道，设备（串行线路等或伪终端），套接字（UNIX，IP4，IP6 - 原始，UDP，TCP），SSL套接字，代理CONNECT连接，文件描述符（stdin等），GNU行编辑器（readline），程序或其中两个的组合。这些模式包括生成“侦听”套接字、命名管道和伪终端。
sox                 : SoX 是一种命令行音频处理工具，特别适合进行快速、简单的编辑和批处理。
starship            : shell
udev
upower
util-linux          : util-linux 是由 Linux 内核组织分发的标准软件包，用作 Linux 操作系统的一部分。
xorg-rander         : xorg-rander
wget                : 下载工具
wireplumber         : pipewire 前端
yad                 : 程序允许您从命令行或 shell 脚本显示 GTK+ 对话框。 [xwayland]
wl-recorder         : 原始的录屏程序

# AUR
cava                : 音频可视化
lexend-fonts-git    : font
geticons            : icon获取，一个 cli 实用程序，用于按名称获取系统上应用程序的图标或其他通用图标。
gojq                : jq 的全go实现 [jq]
gtklock             : lock screen
gtklock-playerctl-module : 锁屏页面显示信息
gtklock-powerbar-module  : module
gtklock-userinfo-module  : module
hyprland-git             : hyprland
python-material-color-utilities : 用于材质颜色的材质-颜色-实用程序的 Python 端口
swww                     : 壁纸
ttf-material-symbols-git : symbol-fonts
wlogout                  : logout面板
showmethekey             : 按键显示


# other
yazi                    : cli file manager [ranger] [custom config copy]
````


## BUG state
 eww中脚本引起的重复进程

 - eww 面板中的todo list delete 报错缺失 `libboost_iostreams.so.1.81.0`
 在安装 boost boost-libs 之后将 `libboost_iostreams.so.1.83.0` 软连接到 `libboost_iostreams.so.1.81.0`

 - 系统信息显示报错

 - 歌曲切换报错 stderr of `volume`: Invalid non-ASCII

 - 配置中的 ERROR



## clean configura
- dashboard : 只能找到 toggle-dashboard.sh 并存在对应的keybind，但是实际上eww并没有这个窗口


## 模拟右键点击 [未测试]
[PeterCxy/scroll-emulation: Middle button scrolling emulation for Wayland (tested on GNOME Wayland) --- PeterCxy/scroll-emulation：用于Wayland的中间按钮滚动仿真（在GNOME Wayland上测试）](https://github.com/PeterCxy/scroll-emulation)

[GPD Pocket - ArchWiki --- GPD 口袋 - 建筑维基](https://wiki.archlinux.org/title/GPD_Pocket#Wayland)

与Xorg不同，在Xorg下，右键仿真可以通过标准的Xorg配置文件启用，在Wayland下，这样的配置应该由合成器公开，不幸的是，一些合成器（例如GNOME Wayland）没有正确公开这些配置。但是，相关功能在 中 libinput 仍然可用。由于这些合成器通常加载 /etc/profile.d ， LD_PRELOAD 因此可以用来钩接到 libinput 并强制应用这些配置。

## 多点触控 [X11]
[JoseExposito/touchegg: Linux multi-touch gesture recognizer --- JoseExposito/touchegg：Linux 多点触控手势识别器](https://github.com/JoseExposito/touchegg)
[JoseExposito/touche: The desktop application to configure Touchégg --- JoseExposito/touche：用于配置 Touchégg 的桌面应用程序](https://github.com/JoseExposito/touche)
[MarioJim/touchegg-music-client: Widget for music and volume control, connected to touchegg's daemon](https://github.com/MarioJim/touchegg-music-client)

## todo list
- 修复todo list面板添加  []
- 修复音频和屏幕亮度面板 [done]
- 更改dunst通知          [done]
        https://smarttech101.com/how-to-configure-dunst-notifications-in-linux-with-images/
        https://github.com/dunst-project/dunst
        https://github.com/dunst-project/dunst/wiki/Guides
- 启动器替换rofi wofi fuzzel []

# Pacman 源和配置
## Chaotic-aur
[Chaotic-AUR - an automated building repo for AUR packages --- Chaotic-AUR - AUR 包的自动化构建存储库](https://aur.chaotic.cx/)
2023-9-23: chaotic-aur/ftl-sdk PGP密钥报错 造成obs-studio 无法通过chaotic-aur 安装，使用 paru 单独安装aur/ftl-sdk

## powerpill
[powerpill](https://xyne.dev/projects/powerpill/) 使用aria2 和reflector 加速下载
实际上感觉不太好用，但是未进行深入的测试

## aria2 加速
在 pacman 的 XferCommand 中使用 aria2c 不会导致多个软件包的并行下载。Pacman 一次用一个包调用 XferCommand 并等待它完成，然后再调用下一个包。若要并行下载多个程序包，请参阅 Powerpill。
- 安装aira2后在`/etc/pacman.conf`: [options] 添加下列内容
````
XferCommand = /usr/bin/aria2c --allow-overwrite=true --continue=true --file-allocation=none --log-level=error --max-tries=2 --max-connection-per-server=2 --max-file-not-found=5 --min-split-size=5M --no-conf --remote-time=true --summary-interval=60 --timeout=5 --dir=/ --out %o %u
````
