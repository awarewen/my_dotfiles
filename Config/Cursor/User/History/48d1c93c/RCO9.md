# 壁纸切换临时文件功能说明

## 功能概述

`switchwall.sh` 脚本现在支持使用临时文件来保存和读取壁纸路径。这个功能可以让您：

1. 快速切换到之前保存的壁纸
2. 在脚本重启后保持壁纸状态
3. 更方便地管理壁纸切换

## 临时文件位置

临时文件保存在：`$XDG_CACHE_HOME/quickshell/wallpaper_path.tmp`

## 新增的命令行选项

### `--show-current`
显示当前临时文件中保存的壁纸路径：
```bash
./switchwall.sh --show-current
```

### `--clear-temp`
清除临时文件：
```bash
./switchwall.sh --clear-temp
```

### `--noswitch`
使用临时文件中的壁纸路径进行颜色主题切换（不切换壁纸）：
```bash
./switchwall.sh --noswitch
```

## 自动行为

1. **自动保存**：每次切换壁纸时，路径会自动保存到临时文件
2. **自动读取**：当没有指定图片路径时，脚本会优先尝试从临时文件读取
3. **回退机制**：如果临时文件不存在或文件不存在，会回退到原来的行为

## 使用示例

```bash
# 切换壁纸（会自动保存到临时文件）
./switchwall.sh /path/to/wallpaper.jpg

# 使用临时文件中的壁纸重新生成颜色主题
./switchwall.sh --noswitch

# 查看当前保存的壁纸路径
./switchwall.sh --show-current

# 清除临时文件
./switchwall.sh --clear-temp
```

## 注意事项

- 临时文件会在每次切换壁纸时自动更新
- 如果临时文件中的路径指向的文件不存在，脚本会回退到文件选择器
- 临时文件存储在缓存目录中，系统重启后仍然存在 