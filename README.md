# Pictures

- Waybar Bar
<p align="center">
  <img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230821-004518.png" width=49%>
  <img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230826-011849.png" width=49%>
</p>

<p align="center">
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230828-055313.png" width=100%>
</p>
---
- Eww Bar
<p align="center">
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230927-224915.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230929-232918.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230929-232945.png" width=49%>
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230929-234122.png" width=49%>
</p>

---

# 说明
*仓库文件结构*
    - `Config` : `$HOME/.config/` 下的配置文件
    - `HOME` : `$HOME/` 下的文件
    - `dotfile_state.md` : 此仓库的状态请查看 `dotfile_state.md` 文件
    - `keybind.md` : 配置中除去某些软件中一些默认的快捷键外，所有相关的快捷键请查看 `keybind.md` 文件
    - 

- 此配置触控功能为 [GPD Pocket 3](http://www.softwincn.com/gpdpocket3) 或类似触屏便携设备适配，其他不具备触控设备可按需要对某些冗余配置进行删减或更改


- 系统信息预览
````
硬件设备: GPD Pocket 3
OS  : Arch linux
Resolutions : 1920x1200, 3840x2160
WM  : Hyprland
shell : zsh
Terminal : kitty,foot(bk)
Bar : eww,waybar-hyprland(bk)
File-manager : thunar,ranger
File system : btrfs
````

## 所有个人使用的软件和依赖程序列表
*重要* : 建议系统关键功能请按列表安装，否则请按相应功能修复相关功能脚本
````
# Dot 各个方面正常运行的基本要求列表
    - 系统资源/进程监视器   : btop
    - 音频可视化            : cava
    - Audio                 : pipewire
    - 屏幕亮度              : light
    - 通知                  : dunst
    - 系统信息显示          : fastfetch (待更新至 config.jsonc 配置格式)
    - Bar                   : waybar-hyprland-git (待考虑 EWW)
    - 浏览器                : firefox-developer-edition
    - 文件管理器            : thunar(GUI),ranger(CLI)
    - 终端                  : kitty
    - 锁屏                  : swaylock, swayidle (DPMS support), swaylock-effects-git
    - 剪切板                : cliphist , wl-clip-persist-git, wl-clipboard
    - 截屏                  : grim, slurp, swappy, imv
    - 应用启动器            : rofi
    - json 解释             : jq, gojq

# 可选的补充推荐软件列表
    - 文本编辑器            : neovim(CLI，截图中配置使用 [Evgeni Chasnovski dotfile](https://github.com/echasnovski/nvim) ), vscode(GUI)
    - 音乐播放器            : go-musicfox(CLI,网易云第三方), music-you(网易云第三方), g4music(本地GUI播放器)
    - 图片预览              : kitty(CLI,kitty +kitten ica), ranger(CLI, preview with kitty), vimiv(GUI, vim like keybind)
    - 视屏播放              : mpv(CLI,本地)
    - 手机投屏              : scpcrcpy-appimage
    - 局域网文件分享        : localsend-bin
    - GAMA 屏幕伽马值       : wlsunset
    - 串口连接              : tinyserial(提供com命令)

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
- Flameshot 在 hyprland 下无法正常使用，且也没其他截屏软件可代替的情况下，由于"grim+slurp"无法暂停屏幕截屏，即采用以下曲线救国的方案。(感谢群友"[maya](https://mayapony.site/)"以及其他群佬提供方案)
基于这个想法目前已经可以截取当前活动窗口的截图
````
bind = $MAIN_MOD   $CTRL_MOD, 1,   exec,                             notify-send "选区截图发送至剪切板" && grim -g "$(slurp)" - | wl-copy     # ## 选区截图发送至剪切板
bind = $MAIN_MOD   $CTRL_MOD, 2,   exec, [noanim]                    notify-send "选区截图" && grim -g "$(slurp)" - | swappy -f -         # ## 选区截图
bind = $MAIN_MOD   $CTRL_MOD, 3,   exec, [float;noanim;toggleopaque] notify-send "截取当前活动窗口发送至剪切板" && grim -g "$(hyprctl activewindow -j | jq '.at[0], $a, .at[1], $b, .size[0], $c, .size[1]' -j --arg a ',' --arg b ' ' --arg c 'x')" - | wl-copy # ## 截取当前显示器全屏并拷贝至剪切板
bind = $MAIN_MOD   $CTRL_MOD, 4,   exec, [float;noanim;toggleopaque] notify-send "截取当前显示器全屏并拷贝至剪切板" && grim -o "$(hyprctl monitors -j | jq '.[] | select(.focused == true) | .name' -r)" - | wl-copy                                        # ## 截取当前显示器全屏并拷贝至剪切板
bind = $MAIN_MOD   $CTRL_MOD, 5,   exec, [float;noanim;toggleopaque] notify-send "暂停截屏" && grim -o $(hyprctl monitors -j | jq '.[] | select(.focused == true) | .name' -r) - | imv -f - & grim -g "$(slurp)" - | swappy -f - && killall imv-wayland   # ## 暂停屏幕（伪）截屏
````

## EWW (支持tray)
- install: `yay -S eww-tray-wayland-git` , Arch Yes!


## 重要
还有很多东西没有补充完整，每天有空就会完善。

## 感谢，本配置参考以下 RICE，它们都各具特点

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland/tree/m3ww) ：作者很多实现的配置十分符合我的口味，我本来打算自己做现在可以偷懒了 ：）
- [flick0/dotfiles](https://github.com/flick0/dotfiles) :我的配置是从此开始的，尽管现在我的配置已经面目全非了 ：）

再次感谢!
