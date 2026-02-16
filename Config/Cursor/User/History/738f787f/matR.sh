#!/usr/bin/env bash
# Wine 中文编码快速修复脚本
# 专门用于解决中国电信等应用程序的乱码问题

set -e

WINE_PREFIX="${WINEPREFIX:-$HOME/.wine}"

echo "=========================================="
echo "Wine 中文编码修复工具"
echo "=========================================="
echo ""

# 检查 Wine prefix
if [ ! -d "$WINE_PREFIX" ]; then
    echo "错误: Wine prefix 不存在: $WINE_PREFIX"
    echo "请先运行: winecfg"
    exit 1
fi

echo "1. 配置注册表代码页为 GBK (936)..."
REG_FILE=$(mktemp)
cat > "$REG_FILE" <<'EOF'
REGEDIT4

[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Nls\CodePage]
"ACP"="936"
"OEMCP"="936"
"MACCP"="936"

EOF

WINEPREFIX="$WINE_PREFIX" wine regedit "$REG_FILE" 2>/dev/null && echo "  ✓ 代码页已设置为 GBK (936)"
rm -f "$REG_FILE"

echo ""
echo "2. 检查并建议安装字体..."
if command -v winetricks >/dev/null 2>&1; then
    echo "  建议运行以下命令安装中文字体："
    echo "    WINEPREFIX=$WINE_PREFIX winetricks corefonts cjkfonts"
    echo "  这将安装 SimSun、SimHei、MingLiU 等常用中文字体"
else
    echo "  警告: 未找到 winetricks，请先安装："
    echo "    sudo pacman -S winetricks  # Arch Linux"
    echo "    或使用您的发行版的包管理器安装"
fi

echo ""
echo "3. 创建优化的启动脚本..."
WRAPPER="$HOME/Downloads/run_chinese_app.sh"
cat > "$WRAPPER" <<'WRAPEOF'
#!/usr/bin/env bash
# Wine 中文应用程序启动脚本

export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"

# 优先尝试 GBK 编码（中国应用程序常用）
if locale -a 2>/dev/null | grep -qiE "zh_CN\.(gbk|GBK)"; then
    export LANG=zh_CN.GBK
    export LC_ALL=zh_CN.GBK
    export LC_CTYPE=zh_CN.GBK
elif locale -a 2>/dev/null | grep -qiE "zh_CN\.(gb18030|GB18030)"; then
    export LANG=zh_CN.GB18030
    export LC_ALL=zh_CN.GB18030
    export LC_CTYPE=zh_CN.GB18030
else
    # 回退到 UTF-8
    export LANG=zh_CN.UTF-8
    export LC_ALL=zh_CN.UTF-8
    export LC_CTYPE=zh_CN.UTF-8
fi

# Wine 相关设置
export WINEDEBUG=-all
export WINEDLLOVERRIDES="mscoree,mshtml="

APP="$1"
if [ -z "$APP" ]; then
    echo "用法: $0 <程序路径>"
    exit 1
fi

cd "$(dirname "$APP")"
exec wine "$APP" "${@:2}"
WRAPEOF

chmod +x "$WRAPPER"
echo "  ✓ 已创建: $WRAPPER"

echo ""
echo "=========================================="
echo "修复完成！"
echo "=========================================="
echo ""
echo "下一步："
echo ""
echo "1. 安装 GBK locale（如果还没有）："
echo "   sudo sed -i 's/#zh_CN.GBK GBK/zh_CN.GBK GBK/' /etc/locale.gen"
echo "   sudo sed -i 's/#zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/' /etc/locale.gen"
echo "   sudo locale-gen"
echo ""
echo "2. 安装中文字体（强烈推荐）："
echo "   WINEPREFIX=$WINE_PREFIX winetricks corefonts cjkfonts"
echo ""
echo "3. 使用新的启动脚本运行程序："
echo "   $WRAPPER ~/Downloads/10000.gd_speedtest.exe"
echo ""
echo "如果问题依然存在，请检查："
echo "  - 字体是否正确安装: ls $WINE_PREFIX/drive_c/windows/Fonts/ | grep -i sim"
echo "  - 注册表代码页: WINEPREFIX=$WINE_PREFIX wine reg query 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Nls\CodePage' /v ACP"
echo ""

