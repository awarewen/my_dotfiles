# Pictures

- Waybar Bar
<p align="center">
  <img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_waybar7.png" width=49%>
  <img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_waybar9.png" width=49%>
</p>

<p align="center">
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_waybar10.png" width=100%>
</p>

---

- Eww Bar
<p align="center">
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_eww1.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_eww2.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_eww3.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_eww4.png" width=49%>
</p>

---

- Aylurs-gtk-shell Bar
<p align="center">
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_ags1.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_ags2.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/hyprland_ags3.png">
</p>

---

# 说明
**仓库文件结构**
> 
````
    - `Config`           : `$HOME/.config/` 下的配置文件
    - `HOME`             : `$HOME/` 下的文件
    - `dotfile_state.md` : 此仓库的状态请查看 `dotfile_state.md` 文件
    - `keybind.md`       : 配置中除去某些软件中一些默认的快捷键外，所有相关的快捷键请查看 `keybind.md` 文件
````

> **重要**  
此配置触控功能为 [GPD Pocket 3](http://www.softwincn.com/gpdpocket3) 或类似触屏便携设备适配，其他不具备触控设备可按需要对某些冗余配置进行删减或更改
上述的截图中所使用的几种 "Bar" 仅作推荐列表，"Bar" 所使用的配置在此列出:

EWW:
     https://github.com/end-4/dots-hyprland
Waybar:

Ags:


## 系统信息预览
````
硬件设备     : GPD Pocket 3
OS           : Arch linux
Resolutions  : 1920x1200, 3840x2160
WM           : Hyprland
shell        : zsh
Terminal     : kitty,foot(bk)
Bar          : eww,waybar-hyprland(bk)
File-manager : thunar,ranger
File system  : btrfs
````

## 所有个人使用的软件和依赖程序列表
> **重要** : 建议系统关键功能请按列表安装，否则请按相应功能修复相关功能脚本
````
# Dot 各个方面正常运行的基本要求列表
    - 系统资源/进程监视器   : btop
    - 音频可视化            : cava
    - Audio                 : pipewire, playerctl
    - 屏幕亮度              : light / brightness
    - 通知                  : dunst / inotify-tools
    - 系统信息显示          : fastfetch (待更新至 config.jsonc 配置格式) , guifetch (https://github.com/FlafyDev/guifetch?ref=flutterawesome.com)
    - Bar                   : aylurs-gtk-shell [https://github.com/Aylur/ags] / (waybar-hyprland-git / Eww)
    - 浏览器                : firefox-developer-edition firefox
    - 文件管理器            : thunar(GUI), ranger(CLI)
    - 终端                  : kitty
    - 锁屏                  : swaylock, swayidle (DPMS support), swaylock-effects-git
    - 剪切板                : cliphist , wl-clip-persist-git, wl-clipboard
    - 截屏录屏              : grim, slurp, swappy, imv , obs-studios-tytan652
    - 应用启动器            : rofi / wofi
    - json 解释             : jq / gojq

# 可选的补充推荐软件列表
    - 文本编辑器            : neovim(CLI，截图中配置使用 [Evgeni Chasnovski dotfile](https://github.com/echasnovski/nvim) ), vscode(GUI)
    - 音乐播放器            : go-musicfox(CLI,网易云第三方), music-you(网易云第三方), g4music(本地GUI播放器), kew (cli 本地播放器)
    - 图片预览              : kitty(CLI,kitty +kitten ica), ranger(CLI, preview with kitty), vimiv(GUI, vim like keybind)
    - 视屏播放              : mpv(CLI,本地)
    - 手机投屏              : scpcrcpy-appimage
    - 局域网文件分享        : localsend-bin
    - GAMA 屏幕伽马值       : wlsunset
    - 串口连接              : tinyserial(提供com命令)
    - 流程图                : drawio
    - 图片管理              : xnviewmp
    - logout                : wlogout
    - 颜色选取              : hyprpicker
    - gtk-theme(2.0,3.0)    : nwg-look
    - 屏幕虚拟键盘          : wvkbd (cli command: wvkbd-mobintl -L 300)

# 笔记本上可用的软件 (适配于GPD pocket 3)
    - 电源管理              : tlp
    - 屏幕自动旋转          : iio-hyprland
    - 摄像头                : 
    - 触控屏幕              : lisgd(work fine with iio-hyprland，触屏 手写笔)
````

## Dotfile 依赖安装
````
# Hyprland 正常运行所需
## xdg-desktop-portal-hyprland-git, xdg-desktop-portal-gtk-git(support file picker), qt5-wayland, qt6-wayland 作为 portal support
# ------------------------------------------------
yay -S python rustup hyprland-git xdg-desktop-portal-hyprland-git-git xdg-desktop-portal-gtk-git polkit-kde-agent qt5-base qt5-wayland qt6-base qt6-wayland wl-clipboard playerctl kitty network-manager-applet light firefox-developer-edition swaylock swayidle swaylock-effects-git grim slurp rofi


# 建议的必要程序
yay -S xdg-desktop-portal waybar-hyprland-git cliphist wl-clip-persist-git neovim code code-features code-marketplace ranger thunar swappy

# 建议的可选程序
yay -S xdg-user-dirs cava btop g4music music-you go-musicfox vimiv tlp mpv scpcrcpy-appimage localsend-bin wlsunset 

# 字体
````

## 子模块
- ranger plugin: zoxide
- Mozilla css:
````
git submodule update --init --recursive
````

## 配置拆分

## Clipboard setting (剪切板配置)
- `wl-clipboard`: 提供 wayland 剪贴板支持

- `cliphist`: 支持文本和图片的剪贴板包装应用
  - clipboard store show whith wofi

- wl-clip-persist: 长时间保存剪贴板数据
````
# ~/.config/hypr/hyprland/keybind.conf
bind = SUPER, V, exec, cliphist list | rofi -dmenu -theme "$HOME/.config/rofi/launchers/type-2/style-1" | cliphist decode | wl-copy

# ~/.config/hypr/hyprland/exec-once.conf
exec-once = wl-paste --type text --watch cliphist store   #Stores only text data
exec-once = wl-paste --type image --watch cliphist store  #Stores only image data
exec-once = wl-clip-persist --clipboard both              # Use Regular and Primary clipboard,long :w
````

## Screenshots (截屏)
- ~Flameshot 不再使用，且也没其他截屏软件可代替的情况下，由于"grim+slurp"无法暂停屏幕截屏~，即采用以下曲线救国的方案。(感谢群友"[maya](https://mayapony.site/)"以及其他群佬提供方案)
 一、基于这个想法目前已经可以截取当前活动窗口的截图
````
# Screenshot 截图
# ___________________________________________________________________
bind = $MAIN_MOD, S, submap, Screenshot
submap=Screenshot
  bind = , 1,   exec,                             grim -g "$(slurp -d)" - | wl-copy  && notify-send "选区截图发送至剪切板"    # ## 选区截图发送至剪切板
  bind = , 2,   exec, [noanim]                    grim -g "$(slurp -d)" - | swappy -f - && notify-send "选区截图"            # ## 选区截图
  bind = , 3,   exec, [float;noanim;toggleopaque] grim -g "$(hyprctl activewindow -j | gojq '.at[0]-20, $a, .at[1]-20, $b, .size[0]+40, $c, .size[1]+40' -j --arg a ',' --arg b ' ' --arg c 'x')" - | wl-copy && sleep 1.0 && notify-send "截取当前活动窗口发送至剪切板"  # ## 截取当前活动窗口发送至剪切板     (Send a screenshot of the currently active window to the clipboard)
  bind = , 4,   exec, [float;noanim;toggleopaque] grim -o "$(hyprctl monitors -j | gojq '.[] | select(.focused == true) | .name' -r)" - | wl-copy && notify-send "截取当前显示器全屏并拷贝至剪切板"                                              # ## 截取当前显示器全屏并拷贝至剪切板 (take screenshot and send to clipboard)
  bind = , 5,   exec, [float;noanim;toggleopaque] grim -o "$(hyprctl monitors -j | gojq '.[] | select(.focused == true) | .name' -r)" - | imv -f - & grim -g "$(sleep 0.5 && slurp -d)" - | swappy -f - & killall imv-wayland && notify-send "暂停截屏"           # ## 暂停屏幕（伪）截屏          (Pause screenshot)
## 脚本待移动到hypr_scripts_dir 通知需要重构 配合eww 显示状态
  bind = , R,   exec, [float;noanim;toggleopaque] $LOCAL_BIN_DIR/record-script.sh & notify-send "wf-recorder 开始录制" && $REST
  bind = , Q,   execr, /usr/bin/kill --signal SIGINT wf-recorder & notify-send "wf-recorder 停止录制" && $REST
## 退出一级 submap
bind = , S,      submap, reset
bind = , S,      execr,  pkill imv-wayland
bind = , escape, submap, reset
bind = , escape, execr,  pkill imv-wayland
submap=reset
````

二、脚本化

````
# Screenshot 截图
bind = $MAIN_MOD, S, submap, Screenshot
submap=Screenshot
bind = , 1, execr, $HYPR_SCRIPTS_DIR/screenshot 1 5 2 && $RESET_MAP # 选区截屏后编辑
bind = , 2, execr, $HYPR_SCRIPTS_DIR/screenshot 2 3 2 && $RESET_MAP # 全屏截图
bind = , 3, execr, $HYPR_SCRIPTS_DIR/screenshot 3 5 2 && $RESET_MAP # 活动窗口截图
bind = , 4, execr, $HYPR_SCRIPTS_DIR/screenshot 4 5 1 && $RESET_MAP # 选区截屏后发送剪切板
# 退出一级 submap
bind = , S,      submap, reset
bind = , escape, submap, reset
submap=reset
````

## Bars
- waybar
- EWW (不完善的Tray)
    - install: `yay -S eww-tray-wayland-git` , Arch Yes!

- AGS (Tray)
    - install: `yay -S aylurs-gtk-shell-git sassc inotify-tools`

- quickshell
    - install: `yay -S quickshell-git`


## keybind 的主要思路
为了避免占用其他的功能键 `ctrl, alt` 导致快捷键冲突，将不同的桌面操作的快捷键分成多个 `submap`，更好的统一快捷键减少记忆的负担和使用成本
- `Submap` 的嵌套
```
# 进入 submap
bind = x, x, submap, Action
submap=Action
    ...
    # 子项
    bind = x, x, submap, Action_2
    submap=Action_2

        # 其他快捷键
        bind = x,x,xxx

        # 返回上一层的 Action submap
        bind = x, x, submap, Action
        # 退出当前整个 submap
        bind = x, x, submap, reset

    # 子项 2
    bind = x, x, submap, Action_3
    submap=Action_3

        # 其他快捷键
        bind = x,x,xxx

        # 返回上一层的 Action submap
        bind = x, x, submap, Action
        # 退出当前整个 submap
        bind = x, x, submap, reset
            # 子项 2-1
            bind = x, x, submap, Action_2-1
            submap=Action_2-1

                # 其他快捷键
                bind = x,x,xxx

                # 返回上一层的 Action submap
                bind = x, x, submap, Action
                # 退出当前整个 submap
                bind = x, x, submap, reset

退出当前整个 submap
bind = x, x, submap, reset
submap=reset
```


## 2023/10/21 修复
目前先将 end-4/dots-hyprland 中所有功能恢复正常工作，再开始修改以及添加新功能


## 感谢，本配置参考以下 RICE，它们都各具特点

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland/tree/m3ww) ：作者很多实现的配置十分符合我的口味，我本来打算自己做现在可以偷懒了 ：）
- [flick0/dotfiles](https://github.com/flick0/dotfiles) :我的配置是从此开始的，尽管现在我的配置已经面目全非了 ：）
- [Aylur/dotfiles](https://github.com/Aylur/dotfiles)

再次感谢!
