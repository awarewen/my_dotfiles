# Picture

<p align="center">
  <img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230821-004518.png" width=49%>
  <img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230826-011849.png" width=49%>
</p>

<p align="center">
<img src="https://github.com/awarewen/my_dotfiles/blob/main/Home/Picture/Screenshots/hyprland/swappy-20230828-055313.png" width=100%>
</p>

---
# TODO list:
````
    README 补全
    dunst  通知的个性美化
    窗口，工作区与快捷键
    配置中的各个部分的联动部分完善
````

# 说明
- 此配置为 [GPD Pocket 3](http://www.softwincn.com/gpdpocket3) 设备适配，其他设备可能需要对某些冗余配置进行删减或更改
- 避免在 Dotfile 关键程序/依赖部分使用过于 "新" 的软件版本，目的在于增加桌面稳定性
````
设备: GPD Pocket 3
OS  : Arch linux
WM  : Hyprland
Bar : waybar hyprland
Terminal: kitty,foot(bk)
File-manager: thunar,ranger
Resolutions: 1920x1200, 3840x2160
````

## 配置状态
````
# Dot 各个方面正常运行的基本要求列表
    - 系统资源/进程监视器   : btop
    - 音频可视化            : cava
    - Audio                 : pipewire
    - 屏幕亮度              : light
    - 通知                  : dunst
    - 系统信息显示          : fastfetch (待更新至 config.jsonc 配置格式)
    - Bar                   : waybar-hyprland (待考虑 EWW)
    - 浏览器                : firefox-developer-edition
    - 文件管理器            : thunar(GUI),ranger(CLI)
    - 终端                  : kitty
    - 锁屏                  : swaylock, swayidle (DPMS support), swaylock-effects-git
    - 剪切板                : cliphist , wl-clip-persist-git, wl-clipboard
    - 截屏                  : grim, slurp, swappy

# 可选的补充推荐软件列表
    - 文本编辑器            : neovim(CLI), vscode(GUI)
    - 音乐播放器            : go-musicfox(CLI,网易云第三方), music-you(网易云第三方), g4music(本地GUI播放器)
    - 图片预览              : kitty(CLI,kitty +kitten ica), ranger(CLI, preview with kitty), vimiv(GUI, vim like keybind)
    - 视屏播放              : mpv(CLI,本地)
    - 手机投屏              : scpcrcpy-appimage
    - 局域网文件分享        : localsend-bin
    - GAMA 屏幕伽马值       : wlsunset

# 笔记本上可用的软件 (适配于GPD pocket 3)
    - 电源管理              : tlp
    - 屏幕自动旋转          : iio-hyprland
    - 摄像头                : 
    - 触控屏幕              : lisgd(work fine with iio-hyprland，触屏 手写笔)
````

## Dotfile 依赖列表
````
# Hyprland 正常运行所需
yay -S hyprland xdg-desktop-portal-hyprland polkit-kde-agent qt5-base qt5-wayland qt6-base qt6-wayland wl-clipboard playerctl kitty network-manager-applet light

# 建议的必要程序
yay -S xdg-desktop-portal waybar-hyprland cliphist wl-clip-persist-git

# 建议的可选程序
yay -S xdg-user-dirs cava btop g4music music-you go-musicfox 

# 字体
````

## 子模块
- ranger plugin: zoxide
- Mozilla css:
````
git submodule update --init --recursive
````

## 重要
还有很多东西没有补充完整，每天有空就会完善。

在此感谢所有开源项目的作者，如果没有他们这个世界将充满黑暗!
