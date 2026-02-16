#!/usr/bin/env bash
# Wine 中文字体乱码修复脚本

set -e

WINE_PREFIX="${WINEPREFIX:-$HOME/.wine}"
FONT_DIR="$WINE_PREFIX/drive_c/windows/Fonts"

if [ ! -d "$WINE_PREFIX" ]; then
    echo "错误: Wine prefix 不存在: $WINE_PREFIX"
    echo "请先运行 winecfg 初始化 Wine"
    exit 1
fi

# 确保字体目录存在
mkdir -p "$FONT_DIR"

echo "正在修复 Wine 中文字体..."

# 查找系统中的中文字体
find_font() {
    local font_name="$1"
    fc-list :lang=zh | grep -i "$font_name" | head -1 | cut -d: -f1
}

# 将系统字体链接到 Wine 字体目录
link_font() {
    local font_file="$1"
    local target_name="$2"
    
    if [ -f "$font_file" ] && [ ! -e "$FONT_DIR/$target_name" ]; then
        ln -sf "$font_file" "$FONT_DIR/$target_name"
        echo "已链接: $target_name -> $(basename $font_file)"
        return 0
    fi
    return 1
}

# 查找并链接常用中文字体
echo "查找系统字体..."

# 查找思源黑体（用作 SimHei 和 SimSun 的替代）
source_han_sans=$(find_font "Source Han Sans CN" | head -1)
if [ -n "$source_han_sans" ]; then
    # 创建字体替换链接
    link_font "$source_han_sans" "simhei.ttf"  # 黑体
    link_font "$source_han_sans" "simsun.ttc"  # 宋体
    link_font "$source_han_sans" "msyh.ttf"    # 微软雅黑
    link_font "$source_han_sans" "msyhbd.ttf"  # 微软雅黑 Bold
fi

# 查找思源宋体
source_han_serif=$(find_font "Source Han Serif CN" | head -1)
if [ -n "$source_han_serif" ]; then
    link_font "$source_han_serif" "songti.ttf"
fi

# 查找 Noto Sans CJK
noto_sans=$(find_font "Noto Sans CJK" | head -1)
if [ -n "$noto_sans" ]; then
    link_font "$noto_sans" "simsun.ttf"
    link_font "$noto_sans" "simhei.ttf"
fi

# 查找文泉驿字体
wqy_font=$(fc-list :lang=zh | grep -i "WenQuanYi\|文泉驿" | head -1 | cut -d: -f1)
if [ -n "$wqy_font" ]; then
    link_font "$wqy_font" "wqy-microhei.ttc"
fi

# 配置 Wine 注册表字体替换和编码设置
echo "配置 Wine 注册表字体映射和字符编码..."

# 创建注册表脚本
REG_FILE=$(mktemp)
cat > "$REG_FILE" <<'EOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
"SimSun"="Source Han Sans CN"
"NSimSun"="Source Han Sans CN"
"SimHei"="Source Han Sans CN"
"Microsoft YaHei"="Source Han Sans CN"
"KaiTi"="Source Han Sans CN"
"FangSong"="Source Han Sans CN"
"MingLiU"="Source Han Sans CN"
"PMingLiU"="Source Han Sans CN"
"MS Gothic"="Source Han Sans CN"
"MS PGothic"="Source Han Sans CN"
"MS UI Gothic"="Source Han Sans CN"
"MS Mincho"="Source Han Sans CN"
"MS PMincho"="Source Han Sans CN"

[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Nls\CodePage]
"ACP"="936"
"OEMCP"="936"
"MACCP"="10008"

EOF

# 导入注册表
WINE_PREFIX="$WINE_PREFIX" wine regedit "$REG_FILE" 2>/dev/null || {
    echo "警告: 注册表导入失败，尝试手动导入..."
    echo "请运行: WINEPREFIX=$WINE_PREFIX wine regedit $REG_FILE"
}

rm -f "$REG_FILE"

echo ""
echo "字体修复完成！"
echo ""
echo "如果仍有乱码问题，可以尝试："
echo "1. 运行: WINEPREFIX=$WINE_PREFIX winecfg"
echo "   在 'Graphics' 标签页中设置 DPI 为 96"
echo ""
echo "2. 使用 winetricks 安装字体包："
echo "   WINEPREFIX=$WINE_PREFIX winetricks corefonts cjkfonts"
echo ""
echo "3. 重新运行应用程序"

