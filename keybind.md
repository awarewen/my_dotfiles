# 快捷键文档

- Prefix
```
../hypr/hyprland/env.conf

$MAIN_MOD  = SUPER
$ALT_MOD   = ALT
$CTRL_MOD  = CTRL
$SHIFT_MOD = SHIFT

$MAIN_CTRL_MOD  = $MAIN_MOD $CTRL_MOD
$MAIN_ALT_MOD   = $MAIN_MOD $ALT_MOD
$MAIN_SHIFT_MOD = $MAIN_MOD $SHIFT_MOD
```

以 `SUPER` 按键为核心，尽量避免与其他应用快捷键产生冲突
退出当前的 `Submap` 状态一般是进入`Submap` 的组合字母或者是 `ESC`
- e.g.
    ```
    按下 Submap Prefix : META + W
    1. 退出当前 Submap: ESC
    2. 退出当前 Submap: W
    ```
某些 `Submap` 有嵌套的 `Submap`，可以使用 `BackSpace` 返回上一层的 `Submap`，每层 `Submap` 都通过 `ESC` 或者 组成`Submap Prefix`的单个字母按键 (e.g. `MEATA + W` 需要退出时: `W` ) 直接退出整个 `Submap` 状态

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

## Submap Prefix: `<MAIN + W>`

- 窗口相关
```
    `Q`             : 关闭活动窗口
    `T`             : 窗口浮动切换
    `P`             : 窗口伪平铺切换
    `F`             : 窗口全屏切换
    `G`             : 窗口伪全屏切换 (需要应用支持)
    `META + P`      : 窗口置顶 (仅限浮动窗口)

    `O`             : 当前活动窗口透明和非透明切换
    `L`             : 锁屏
    `E`             : 切换随机壁纸
    `I`             : GuiFetch 应用
    `META + R`      : 重启 Hyprland
    `META + Q`      : Wlogout

    `1 - 8`         : 移动窗口到指定的工作区，需要更多的可以自行添加快捷键
    `J`             : 切换焦点到当前显示器的下一个存在的工作区
    `K`             : 切换焦点当前显示器的上一个存在的工作区
```
- 退出 `submap`
```
    `w`             : 退出当前 `submap`
    `ESC`           : 退出当前 `submap`
```

- 进入二级 `submap` , 将当前活动窗口与指定方向的窗口交换位置: `<META + S>`
```
    `H, J, K, L`    : 指定方向交换
    `N, P`          : 顺序交换 (N : 顺时针的下一个窗口 )
```

- 退出 `submap`
```
    `S`             : 退出当前 `submap`
    `BackSpace`     : 返回上一级 `submap`
```

## Focus

- 工作区焦点
```
    `MAIN + 1 - 8`  : `1 - 8` 工作区
```

## 声音、亮度、音乐控制 Prefix: `<MAIN + E>`

- 音量
```
    `space`         : MUTE 静音切换
    `K`             : 音量+
    `J`             : 音量-
```

- 亮度
```
    `L`             : 亮度+
    `H`             : 亮度-
```

- 媒体
```
    `ALT + J`       : 播放下一首
    `ALT + space`   : 暂停播放 (`playerctl`)
    `ALT + K`       : 播放上一首
```

- 退出 `submap`
```
    `E`
    `ESC`
```

- 单独的功能键
```
    `XF86MonBrightnessUp`   : 亮度+
    `XF86MonBrightnessDown` : 亮度-
    `XF86AudioMute`         : MUTE 静音切换
    `XF86AudioRaiseVolume`  : 音量+
    `XF86AudioLowerVolume`  : 音量-
```

## 窗口组 Prefix: `<MAIN + G>`

- 创建，加入，移出，锁定，解锁
```
    `F`             : 当前活动窗口创建/移出组
    `T`             : 当前活动窗口加入存在的组
    `O`             : 组锁定，不接受新窗口入组
    `U`             : 解除锁定，接受新窗口入组
    `I`             : 切换锁定状态
```

- 组中的窗口切换
```
    `TAB`           : 组中下一个窗口
    `SHIFT + TAB`   : 组中上一个窗口
    `1 - 9 - 0`     : `1 - 9 - 0` 指定组显示的窗口
```

- 在组模式下更改活动窗口焦点
```
    `H, J, K, L`    : 按方向聚焦活动窗口
    `N, P`          : 顺时针/逆时针聚焦当前屏幕活动窗口
```

## 鼠标

- 鼠标拖动
```
    `MAIN + 鼠标左键` : 拖动窗口
    `MAIN + 鼠标右键` : 拖动调整窗口大小
```

## 特殊工作区

- 暂存区 [grave is `\`` key]
```
    `MAIN + ALT + grave` : 将当前活动窗口发送到特殊工作区
    `MAIN + grave`       : 显示和隐藏特殊工作区
    `MAIN + ALT + W`     : 将特殊工作区的活动窗口发送到空白的工作区并平铺
```

## 调整当前窗口大小 Prefix: `<MAIN + R>`

- `size = 20`
```
    `H, J, K, L`
```

- `size = 10`
```
    `Left, Down, Up, Right`
```

- 退出当前 `submap`
```
    `R`
    `ESC`
```

## App 启动

- `kitty`
```
    `MAIN + T`          : 全屏
    `MAIN + RETURN`     : 浮动
    `ALT + RETURN`      : 平铺
```

- `CLI program`
```
    `CTRL + 1`          : Cava
    `CTRL + 2`          : tty-clock
    `CTRL + 3`          : alsamixer
    `CTRL + 4`          : thunar
```

- `Rofi`
```
    `MAIN + space`      : Rofi launcher
    `MAIN + V`          : Text 剪切板历史
```

## 截图，录屏

- grim + slurp + swappy 截屏 Prefix: `<MAIN + S>`
```
    `1`                 : 选区截图并发送至剪切板
    `2`                 : 选区截图并在打开 `swappy` 编辑
    `3`                 : 截取当前活动窗口并发送至剪切板
    `4`                 : 截取当前显示器全屏并发送至剪切板
    `5`                 : 暂停屏幕并进行选区截图，支持多个屏幕
```

- wf-recorder 录屏
```
    `R`                 : 开始录制
    `Q`                 : 退出录制
```

- 退出当前 `submap`
```
    `S`
    `ESC`
```

## `Pot` 翻译

- `exec-once.conf` 中 `Pot` 处于注释状态，正常运行需要 `Pot` 在后台
```
    `ALT + X`           : 选区 进行 OCR 识别翻译
    `ALT + C`           : 选区截图翻译
    `ALT + V`           : 剪切板翻译
    `ALT + B`           : 划词翻译 (模拟终端不支持)
    `ALT + Z`           : 输入同步翻译 (模拟终端不支持)
```
