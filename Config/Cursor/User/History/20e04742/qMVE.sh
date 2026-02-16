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
echo "现在创建一个启动包装脚本来正确设置编码环境..."
echo ""

# 创建启动包装脚本（尝试 GBK 编码）
WRAPPER_SCRIPT="$HOME/Downloads/run_speedtest.sh"
cat > "$WRAPPER_SCRIPT" <<'WRAPEOF'
#!/usr/bin/env bash
# Wine 中文应用程序启动包装脚本（支持 GBK 编码）

export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"

# 尝试 GBK 编码（中国电信应用常用）
# 如果系统没有 GBK locale，则使用 UTF-8
if locale -a | grep -qi "zh_CN.gbk\|zh_CN.GBK"; then
    export LANG=zh_CN.GBK
    export LC_ALL=zh_CN.GBK
    export LC_CTYPE=zh_CN.GBK
    echo "使用 GBK 编码启动..."
else
    # 回退到 UTF-8
    export LANG=zh_CN.UTF-8
    export LC_ALL=zh_CN.UTF-8
    export LC_CTYPE=zh_CN.UTF-8
    echo "使用 UTF-8 编码启动（如果仍有乱码，请安装 GBK locale）..."
fi

# 设置 Wine 的 locale
export WINELOCALEDIR="/usr/share/locale"

# 运行应用程序
APP="$1"
if [ -z "$APP" ]; then
    APP="$HOME/Downloads/10000.gd_speedtest.exe"
fi

cd "$(dirname "$APP")"
wine "$APP" "${@:2}"
WRAPEOF

chmod +x "$WRAPPER_SCRIPT"

echo "已创建启动包装脚本: $WRAPPER_SCRIPT"
echo ""
echo "=========================================="
echo "下一步操作："
echo "=========================================="
echo ""
echo "1. 如果系统缺少 GBK locale，请先安装（推荐）："
echo "   编辑 /etc/locale.gen，添加："
echo "     zh_CN.GBK GBK"
echo "     zh_CN.GB18030 GB18030"
echo "   然后运行: sudo locale-gen"
echo ""
echo "2. 使用 winetricks 安装中文字体（强烈推荐）："
echo "   WINEPREFIX=$WINE_PREFIX winetricks corefonts cjkfonts"
echo "   这将安装 SimSun、SimHei 等常用中文字体"
echo ""
echo "3. 使用包装脚本启动应用程序："
echo "   $WRAPPER_SCRIPT"
echo "   或者直接指定程序："
echo "   $WRAPPER_SCRIPT ~/Downloads/10000.gd_speedtest.exe"
echo ""
echo "4. 如果仍有问题，运行 winecfg 检查："
echo "   WINEPREFIX=$WINE_PREFIX winecfg"
echo "   - 在 'Graphics' 标签页设置 DPI 为 96"
echo "   - 在 'Applications' 标签页设置 Windows 版本为 Windows 7 或 Windows 10"
echo ""
echo "5. 手动测试编码（如果需要）："
echo "   export LANG=zh_CN.GBK LC_ALL=zh_CN.GBK"
echo "   wine ~/Downloads/10000.gd_speedtest.exe"
echo ""

