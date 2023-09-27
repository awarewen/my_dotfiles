# README

出现此文件主要原因是，本人是个 `git fw`， 我的 `commit` 自己都不太能看明白，所以用这个文件来辅助
  > 文件将记录每次所做的更改更新，反映 `Dotfile` 状态，并记录 `todo list` 方便后续整理和后续功能的添加完善
    - 主标记以上传更新时的时间戳区分，次标记为更新主题
    - 完成的 `todo list` 将移动到此文的的结尾

---

# Latest

## 2023/9/28

主要更新了仓库的配置文件结构，把 `README` 中各个主题提取出为单独的 `markdown` 文档，增加可阅读性
目前工作围绕系统通知，让进入 `hyprland submap` 的提示更加人性化一些

### 系统通知

    - 添加音量、亮度、音乐控制脚本 : `Config/hypr/scripts/volume_brightness.sh`
    - 修改 `dunst` 配置，更好的主题颜色，使通知出现在屏幕中间醒目位置 : `Config/dunst/`

### 配置文件仓库文件结构

    - `README.md` : 规范部分内容
    - `dotfile_state.md` : 反应配置仓库的状态
    - `keybind.md` : 快捷键列表待办

---

# Todo List

## 配置仓库

- 配置文件仓库文件结构
    - `keybind.md` : 快捷键列表

- 指定位置存放全局使用的一些资源 (icons, wallpaper等等)
    - icons : `$HOME/Picture/icons/`
    - wallpapers : `$HOME/Picture/wallpapers/`

- 复杂脚本使用性能更好的 `python` 重新实现

## 硬件适配

-  `GPD Pocket 3`
    - `lisgd`
        - 平板模式触控手势脚本，实现 `hyprland` 窗口管理的大部分功能
        - `wvkbd-mobintl` 虚拟键盘 : 划出、隐藏
        - 控制终端滚动
        - 应用启动器 : 启动、输入、隐藏

- 电源
    - 省电脚本

## `hyprland` 配置

- 分离颜色一类的配置，以创建主题

- `hyprland.conf`
    - 配置格式优化，跟进上游最新的配置更改

- `keybind.conf`
    - `pot` 翻译程序相关的快捷键修复
    - `submap` 完善
    - 配置格式优化


## 细化功能

- 系统通知
    - 在进入 `hyprland submap` 时进行通知并固定每个 `submap` 的按键提示
    - 不同等级的系统通知规划在合理的区域
    - 合并脚本管理通知，更加合理的脚本实现
    - `dunst icons` 完善
    - `dunst` 主题配色
    - 分级管理
    - 通知中心

- 截图
    - 功能迁移至脚本实现，将其从与 `hyprland` `keybind` 配置中分离出来，实现在所有截图功能中暂停画面

- 特殊工作区功能修复一些存在的问题，将特殊工作区中窗口发送回普通工作区后自动关闭

- `Eww Bar` : `custom` 配置和脚本修复，目前只有部分功能正常工作
    - 待修复
        - 主题颜色根据壁纸更改
        - `todo list` 添加、提醒
        - `record` 录屏按钮功能工作
        - 使用 `dunst` 替换 `custom` 配置中的 `notify-receive`
        - 将 `Reddit` 图片显示模块替换为其他模块
        - 剔除无用的功能
        - `Logout` 面板
        - `hyprland keybind` 查看面板
    - 触控适配

- 锁屏
    - 界面美化
    - 锁屏显示重要通知 (通知中心)
    - 锁屏后更加合理的亮屏时长，之后正常 `DPMS` 黑屏

- 剪切板
    - `rofi` 列出剪切板图片历史

- 录屏
    - 区域化录屏 (slurp, wl-record)
    - 系统通知


---

# Done List

## 配置仓库
- [Done] | 配置仓库
    - `README.md`: 规范部分内容

## 硬件适配
- [Done] | `GPD Pocket 3`
    - 屏幕
        - `iio-hyprland` 自动旋转工作正常 (firefox 触控滚动，Eww 双侧面板的划出隐藏)
        - `wvkbd-mobintl` 虚拟键盘工作正常
        - `lisgd` 触控手势工作正常
    - 触控笔
    - 休眠

## `hyprland` 配置
- [Done] | `keybind.conf` 配置
    - 使用 `submap` 将所有的相关功能的键绑定合理划分，在后续越来越多的快捷键加入后，减轻记忆负担

- [Done] | `windowrule.conf` 配置
    - 特定应用窗口的浮动
    - 特定应用窗口不透明
    - `Eww` 相关窗口设置

- [Done] | `env.conf`
    - 将其他配置中使用的变量分离集中到此文件

- [Done] | `exec_once.conf`
    - 配置运行所需要启动的所有程序包含在此文件

- [Done] | `hyprland.conf`
    - 贝塞尔动画
    - 透明
    - blur

## 细化功能

- [Done] | 截图
    - 区域截图
    - 活动窗口截图
    - 活动屏幕截图
    - 所有显示器暂停画面截图
    - 截图后添加简单的编辑功能
    - 截图发送剪切板

- [Done] | 特殊工作区
    - 打开关闭
    - 活动窗口快速发送至特殊工作区
    - 特殊工作区中窗口发送至普通工作区

- [Done] | 声音
    - 系统通知
    - `hyprland keybind`
    - 联动 `Eww` 显示
    - 锁屏后相关功能正常使用

- [Done] | 亮度
    - 系统通知
    - `hyprland keybind`
    - 联动 `Eww` 显示
    - 锁屏后相关功能正常使用

- [Done] | 音乐控制
    - 系统通知
    - `hyprland keybind`
    - 联动 `Eww` 显示
    - 锁屏后相关功能正常使用

- [Done] | 系统通知
    - 使通知出现在屏幕中间固定的醒目位置
    - 添加声音、亮度、音乐控制脚本 : `Config/hypr/scripts/volume_brightness.sh`
    - 修改 `dunst` 配置，更好的主题颜色，使通知出现在屏幕中间醒目位置 : `Config/dunst/`

- [Done] | 锁屏
    - 自动 `DPMS` 黑屏
    - 切换壁纸
    - 锁屏后关闭 `Eww`，`iio-hyprland`自动旋转，`swww_randomize.sh`壁纸自动切换脚本等后台，并在解锁后重新运行

- [Done] | 屏幕虚拟键盘 `wvkbd-mobintl` 工作

- [Done] | 剪切板
    - 文件和图片复制粘贴
    - 剪切板持久化
    - `rofi` 列出剪切板文字历史

- [Done] | 壁纸
    - 使用 `swww` 实现壁纸显示、切换
    - `hyprland keybind` 手动切换
    - 定时自动切换脚本
    - 好看且顺滑的切换效果
    - `ranger` 配置中添加自定义切换快捷键

- [Done] | `Eww Bar`
    - 使用 `custom` 配置 : [end-4/dots-hyprland at m3ww](https://github.com/end-4/dots-hyprland/tree/m3ww)
    - 修复
        - `Volume` 和 `Brightness` 的 `osd 条` 显示工作
        - 双侧面板弹出显示、隐藏
        - `gnome-control-center` 大部分功能工作
        - `custom` 配置配套的 `notify-receive` 工作正常

- [Done] | `firefox`
    - 使用 `custom` 主题配置
    - `hyprland windowrule` 对一些网站应用特定的规则 (自动透明切换)
