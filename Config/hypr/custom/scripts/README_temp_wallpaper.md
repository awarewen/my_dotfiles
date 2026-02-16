# 壁纸切换缓存功能说明

## 功能概述

`switchwall.sh` 脚本现在支持图片缓存和自动尺寸调整功能。这个功能可以让您：

1. 自动将图片复制到缓存目录并调整尺寸以适应多屏幕
2. 避免修改原始图片文件
3. 确保壁纸完美适应屏幕尺寸，不留黑边
4. 支持多屏幕配置（如 1920x1200 和 3840x2160）

## 目录结构

- **临时文件**：`$HOME/.cache/wallpaper_path.tmp`
- **缓存目录**：`$HOME/.cache/switchwall/`
- **缓存文件**：`$HOME/.cache/switchwall/wallpaper`

## 新增的命令行选项

### `--show-current`
显示当前临时文件中保存的壁纸路径：
```bash
./switchwall.sh --show-current
```

### `--show-cache`
显示缓存文件信息：
```bash
./switchwall.sh --show-cache
```

### `--clear-temp`
清除临时文件：
```bash
./switchwall.sh --clear-temp
```

### `--noswitch`
使用缓存文件中的壁纸路径进行颜色主题切换（不切换壁纸）：
```bash
./switchwall.sh --noswitch
```

## 自动行为

1. **自动缓存**：每次切换壁纸时，图片会自动复制到缓存目录
2. **自动调整尺寸**：图片会自动调整到最大屏幕尺寸，保持宽高比
3. **智能回退**：如果缓存文件不存在，会回退到原图或文件选择器
4. **覆盖缓存**：每次只保存一个缓存文件，避免目录膨胀

## 尺寸调整逻辑

- 获取所有屏幕的最大宽度和高度
- 计算缩放比例，保持图片宽高比
- 使用 `convert` 命令调整图片尺寸
- 如果图片尺寸已经足够，直接复制不调整

## 使用示例

```bash
# 切换壁纸（会自动缓存并调整尺寸）
./switchwall.sh /path/to/wallpaper.jpg

# 使用缓存文件重新生成颜色主题
./switchwall.sh --noswitch

# 查看当前保存的壁纸路径
./switchwall.sh --show-current

# 查看缓存文件信息
./switchwall.sh --show-cache

# 清除临时文件
./switchwall.sh --clear-temp
```

## 依赖要求

- `convert` (ImageMagick)：用于图片尺寸调整
- `identify` (ImageMagick)：用于获取图片尺寸信息
- `bc`：用于数学计算

## 注意事项

- 缓存文件会覆盖之前的文件，避免目录膨胀
- 原图路径保存在配置文件中，缓存文件路径保存在临时文件中
- 视频文件直接复制，不进行尺寸调整
- 如果 `convert` 命令不可用，会直接复制原图
- 缓存文件在系统重启后仍然存在 