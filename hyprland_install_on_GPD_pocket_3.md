# 安装Arch linux (基础系统安装)
1. 修复以前安装时遗留的问题
3. 重新整理全部配置，以适应更加现代的操作环境

- OS:           arch linux
- File system:  btrfs，开启snapshort
- WM:           hyprland

## TTY旋转 (GPD pocket 3)

- GPD 默认为纵向显示，向帧缓冲区写入旋转参数
````
echo > 1 /sys/class/graphics/fbcon/rotate_all
````

- 设置更大的 TTY 字体
````
setfont ter-u32b
````

## 更新系统时钟，切换源

````
timedatectl set-ntp true

reflector -c China -a 10 --sort rate --save /etc/pacman.d/mirrorlist
````

## 分区
- 采用 `btrfs` 分区格式

### 创建子卷
- 根分区下面采用Ubantu的挂载方案为了使用Timeshift备份系统快照
- `/` && `/home` 为 Timeshift 快照方案必须要的分区

````
- 创建 btrfs 节点
mount /dev/nvme0n1p3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
umount /dev/sda3    # 卸载分区

- 创建目录挂载
-- 根分区
mount /dev/Driver_name /mnt -o subvol=@,noatime,discard=async,compress=zstd

-- 家目录
mkdir /mnt/home
mount /dev/Driver_name /mnt/home -o subvol=@home,noatime,discard=async,compress=zstd

-- logs目录
mkdir /mnt/var/log -p
mount /dev/Driver_name /mnt/var/log -o subvol=@log,noatime,discard=async,compress=zstd

-- pkg 目录
mkdir /mnt/var/cache/pacman/pkg -p
mount /dev/Driver_name /mnt/var/cache/pacman/pkg -o subvol=@pkg,noatime,discard=async,compress=zstd

-- 启用交换分区
swapon /dev/nvme0n1p2
````

- 这两个目录不需要快照，禁用写时复制：

````
chattr +C /mnt/var/log
chattr +C /mnt/var/cache/pacman/pkg
````

### 挂载 boot 分区
````
mkdir /mnt/boot
mount /dev/Driver_name /mnt/boot
````

## 安装系统

1. 安装 base 系统 (xxx-ucode 根据cpu来）
````
pacsteap -k /mnt base base-devel linux linux-headers linux-firmware vim vi neovim btrfs-progs intel-ucode
networkmanager network-manager-applet git openssh zsh dhcpcd grub efibootmgr
````


2. 生成分区表
````
genfstab -U /mnt >> /mnt/etc/fstab
````
3. `arch-chroot` 切换根目录
````
arch-chroot /mnt
````

4. 添加 `btrfs mkinitcpio` Hook
```
nvim /etc/mkinitcpio.conf
_______________________________
MODULES=(btrfs)
-------------------------------

- 保存退出，重新生成initcpio
mkinitcpio -P
```

## Grub Install

- 调整default grub设置 (GPD-Pocket-3)
````
    GRUB_CMDLINE_LINUX_DEFAULT="... fbcon=rotate:1"
    GRUB_CMDLINE_LINUX="... fbcon=rotate:1"
    GRUB_GFXMODE=1200x1920x32
````

- Install
````
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
````

## 杂项
- 修改时区
````
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
````

- 硬件时钟同步
````
hwclock --systohc
````

- 本地化
````
nvim /etc/locale.gen
______________________
en_US.UTF-8 UTF-8
zh_EN.UTF-8 UTF-8
----------------------

- 加载 locale
locale-gen

- 设置locale config
echo LANG=en_US.UTF-8 > /etc/locale.conf
````

- 设置Host
````
echo xxx > /etc/hostname
````
设置hosts 局域网 (hostname is /etc/hostname you set)
```
127.0.0.1	localhost
127.0.0.1	::1
127.0.0.1 	hostname.loacldomain 	hostname
```

## 创建新用户并设置root密码
````
passwd root

- 创建新用户并添加到 wheel 用户组
useradd -m -G wheel -s /bin/bash user

- 设置密码
passwd 'the_user_name'

- 为 wheel 用户组更改用户权限
    EDIOR=vim visudo
    - 找到 'Uncomment to allow members of group wheel to execute any command' 将下一行配置取消注释

````

## AUR
修改pacman.conf即可
添加archlinuxcn源
````
# /etc/pacman.conf
__________________
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
# 并且取消32位库
------------------------------------------------------

# archlinuxcn keyring
pacman -S archlinuxcn-keyring

# AUR helper (可以源码编译)
pacman -S paru-git
````

## 常用软件：
paru -S ntfs-3g clash-meta 

```markdown
### 英文字体
pacman -S ttf-dejavu ttf-droid ttf-hack ttf-font-awesome otf-font-awesome ttf-lato ttf-liberation ttf-linux-libertine ttf-opensans ttf-roboto ttf-ubuntu-font-family

### 中文字体
paru -S ttf-hannom noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk adobe-source-code-pro-fonts \
          adobe-source-sans-fonts adobe-source-serif-fonts adobe-source-han-sans-cn-fonts \
          adobe-source-han-sans-hk-fonts adobe-source-han-sans-tw-fonts adobe-source-han-serif-cn-fonts wqy-zenhei wqy-microhei

symble fonts
paru -S ttc-iosevka-git
```

## TTY Font set
设置tty字体大小
````
yay -S terminus-font
echo FONT=ter-u32b > /etc/vconsole.conf
````

## 开启服务
````
systemctl enable NetworkManager
systemctl ebable sshd

exit
umount -a

reboot
````

## 桌面前的准备
--
安装 XDG dir基本用户文件管理

 sudo pacman -S xdg-user-dirs

## 更改make编译速度 开启多核
nvim /etc/makepkg.conf

为了更快的下载 可以优先配置clash

## Sddm
paru -S sddm-git

## wlr-randr
paru -S wlr-randr

## Dotfiles install
https://github.com/flick0/dotfiles/tree/dreamy

paru -S hyprland-git waybar-hyprland-git cava waybar-mpris-git python rustup kitty fish wofi xdg-desktop-portal-hyprland-git tty-clock-git swaylockd grim slurp pokemon-colorscripts-git starship jq dunst wl-clipboard swaylock-effects-git swww-git zsh tmux ranger sddm-git qt5-base qt5-wayland qt6-base qt6-wayland light blueman network-manager-applet g4music btop polkit-kde-agent
```
git clone -b dreamy https://github.com/flick0/dotfiles
cd dotfiles
cp -r ./config/* ~/.config

mkdir ~/.config/hypr/store
touch ~/.config/hypr/store/dynamic_out.txt
touch ~/.config/hypr/store/prev.txt
touch ~/.config/hypr/store/latest_notif

chmod +x ~/.config/hypr/scripts/tools/*
chmod +x ~/.config/hypr/scripts/*
chmod +x ~/.config/hypr/*

git clone https://github.com/flick0/rgb-rs
cd rgb-rs
cargo build --release
cp ./target/release/rgb ~/.config/hypr/scripts/
```

### https://github.com/PROxZIMA/.dotfiles

paru -S swaync  playerctl   mpd mpd-mpris mpv mpv-mpris qt5-base qt5-wayland qt6-base qt6-wayland lsd geany bat cliphist-bin gamemode  g4music wlogout visual-studio-code-bin  sddm-git boo-sddm-git proxzima-plymouth-git yad blueman network-manager-applet libinput-gestures light --needed


go-musicfox firefox

-- NOTE hostname 命令未找到：install inetutils

## `TLP` 电源管理
- install `tlp` 电源管理和 `tlp-rdw` 无线设备向导
````
yay -S tlp tlp-rdw

sudo systemctl enable tlp
sudo systemctl enable NetworkManager-dispatcher.service
````
- 屏蔽 systemd 服务systemd-rfkill.service 以及套接字 systemd-rfkill.socket 来防止冲突，保证 TLP 无线设备的开关选项可以正确运行

- 以下为 `GPD Pocket 3 TLP` 配置
````
/etc/tlp.conf
-------------
    CPU_SCALING_GOVERNOR_ON_AC=powersave
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    CPU_ENERGY_PERF_POLICY_ON_BAT=power
    CPU_BOOST_ON_AC=1
    CPU_BOOST_ON_BAT=0
    PLATFORM_PROFILE_ON_AC=performance
    PLATFORM_PROFILE_ON_BAT=low-power
    DISK_IOSCHED="mq-deadline"
    PCIE_ASPM_ON_AC=default
    PCIE_ASPM_ON_BAT=powersupersave
````

## 声音
`hyprland` 推荐使用是 `pipewire`

- pipewire
````
# pipewire 内部不实现任何连接逻辑，这些被其他外部组件如会话管理器所负担。
          pipewire
          lib32-pipewire  :32位应用支持
          wireplumber     :目前唯一推荐的会话管理器
          pipewire-pulse  :取代 pulseaudio 和 pulseaudio-bluetooth，（使用 pipewire-pulse.server 替换 pulseaudio.server）'pactl info 查看 "Server Name:PulseAudio (on PipeWire)'" 即成功
          pipewire-audio  :PulseAudio 和 JACK 兼容的服务器实现和 API兼容库来替代它们，处理蓝牙设备连接
          pipewire-alsa   :取代 ALSA 客户端（如果安装了pulseaudio-alsa ，请移除它）
          pipewire-jac   :jack 客户端启动支持
          pipewire-zeroconf   :pipewire 零配置支持（自动配置）
          alsa-utils :提供alsamixer amixer 工具
          lib32-libpipewire 1:0.3.70-1
          libpipewire
          pipewire-jack

 - GPD-Pocket-3 : /etc/modprobe.d/alsa.conf
___________________________________________
    options snd-intel-dspcfg dsp_driver=1
-------------------------------------------
````

## 蓝牙
````
- blueman
yay -S blueman
- Enable service

sudo systemctl enable bluetooth.service
````


## 软件补全
````
curl wget beep (for musicfox) alsa-utils fzf fd ripgrep wl-copy zoxide

tmux

neovide : cargo install --git https://github.com/Yesterday17/neovide.git
````

## 亮度
````
light

````

## polkit
````
- 使用 polkit-kde-agent
yay -S polkit-kde-agent

nvim ~/.config/hypr/autostart
________________________
/usr/lib/polkit-kde-authentication-agent-1 &

````

## 输入法
````
aur/fcitx5-git
aur/fcitx5-chinese-addons-git
aur/fcitx5-qt-git
aur/fcitx5-gtk-git

- 词库
fcitx5-pinyin-sougou 20210320-1
fcitx5-pinyin-zhwiki 1:0.2.4.20230507-1
fcitx5-pinyin-custom-pinyin-dictionary
fcitx5-pinyin-chinese-idiom
````
- 关于 `kitty` 与 `fcitx5`
如果使用 `archcn/fcitx5-git` 的包造成 `fcitx5` 在 `kitty` 无法正常弹出输入法候选框，请安装 `aur/fcitx5-git`。
如果候选框仍然不正常，请检查 `fcitx5:~/.config/fcitx5/conf/classicui.conf` 中 `ForceWaylandDPI=0`。

- ENV (/etc/environment)
````
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
INPUT_METHOD=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
````

## hyprsome
工作区管理

## swww Error
````
daemon (111) failed:
- [Error: Failed to connect to socket in arch linux · Issue #108 · Horus645/swww · GitHub](https://github.com/Horus645/swww/issues/108)
rm ~/run/user/1000/swww/swww.socket
rm ~/.cache/swww/*
````

## 启用GuC HuC (11代intel cpu)
- [如何充分使用英特尔硬件（指南） - FAQ and Tutorials - Garuda Linux Forum](https://forum.garudalinux.org/t/how-to-fully-use-intel-hardware-guide/8193)

````
sudo pacman -S mesa lib32-mesa libva libva-intel-driver\
               libva-mesa-driver libva-vdpau-driver libva-utils\
               lib32-libva lib32-libva-intel-driver lib32-libva-mesa-driver\
               lib32-libva-vdpau-driver intel-ucode iucode-tool vulkan-intel\
               lib32-vulkan-intel intel-gmmlib intel-graphics-compiler intel-media-driver\
               intel-media-sdk intel-opencl-clang libmfx --need

- 添加Hook: /etc/mkinitcpio.conf
________________________
    MOUDULE(intel_agp i915)
------------------------

- 重新生成initcpio
    sudo mkinitcpio -P

- 启用 GuC: /etc/modprobe.d/i915.conf
_____________________________
    options i915 enable_guc=3
    options i915 enable_fbc=1
-----------------------------

- 重新生成 grub.cfg
    sudo grub-mkconfig -o /boot/grub/grub.cfg
````

## The Screen Resolutions
multi-monitor :
DSI-1 : 1200x1920@60Hz
DHMI-A-1 : 3840x2180@60Hz

-- Pos

## Problem :Doesn't work
- Up screen after dpms turn off the screen with mouse
    create a scripts for lock screen
````
    ## turn off screen
    hyprctl dispacth dpms off

    ## open the dpms setting on `~/.config/hypr/hyprland.conf`
    misc {
            mouse_move_enables_dpms = true
        }
````

- Take multiple monitor display Screenshot
    - Not Found

## multiple monitor
[Multiple Monitors with Different Resolutions on Wayland | by Wainaina Gichuhi](https://medium.com/@muffwaindan/using-multiple-monitors-with-different-resolutions-on-wayland-linux-530ef23fc5eb)
-- resolutions: 1920x1080 + 3840x2180

-- grim 截屏仍然不支持在多屏情况下的不同scale(仅支持在scale = 1) 目前没有解决方案

## Screenshot and copy to clipboard keybind
````
bind=SUPER,i,exec,grim -g "$(slurp)" - | wl-copy
````

## 配置firefox [done] AV1 硬解


## hyprland 关于窗口标题与 windows rule
- windows title 和 windows rule 之间存在的影响
- 当指定标题的window在不同模式下(float, tile) 根据不同的 title 不同的表现形式
- 采用多文件形式对多个窗口的配置进行维护
````
bind=SUPER,t,exec,kitty --start-as=fullscreen --title all_is_kitty

windowrule=move center,title:^(fly_is_kitty)$
windowrule=size 800 500,title:^(fly_is_kitty)$
windowrule=animation slide,title:^(all_is_kitty)$
windowrule=float,title:^(all_is_kitty)$
windowrule=tile,title:^(kitty)$
windowrule=float,title:^(fly_is_kitty)$
windowrule=float,title:^(clock_is_kitty)$
windowrule=size 418 234,title:^(clock_is_kitty)$
````
## bind flags
````
l -> locked, aka. works also when an input inhibitor (e.g. a lockscreen) is active.
r -> release, will trigger on release of a key.
e -> repeat, will repeat when held.
n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
m -> mouse, see below
````

## Bug

测试 obs 时发现 在hyprland 下面不能同时开播并更改 hyprland 配置,否则直接崩溃

与 Xorg 不同的是，Wayland 并不允许独占输入设备捕获 (也被称为主动捕获或显式捕获，比如 键盘、鼠标 等设备)。Wayland 依赖混成器传递键盘快捷键，并将指针设备限制在应用窗口中。

输入捕获方式的变化破坏了当前应用程序的行为，意味着：

热键组合和修饰符输入会被混成器捕获，并且不会发送到远程桌面和虚拟机窗口中。
鼠标指针将不会被限制在应用程序的窗口中，这可能会导致视差效应，即虚拟机或远程桌面的窗口内鼠标指针的位置与主机的鼠标指针发生偏差。

## (kooha, peek)
- [phw/peek: Only work on xwayland](https://github.com/phw/peek)
- [SeaDve/Kooha: Elegantly record your screen](https://github.com/SeaDve/Kooha)

