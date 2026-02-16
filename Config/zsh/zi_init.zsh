##############################################################################################################
#
#  -- 如果本地没有下载zi,将会自动下载
#  *  设置基础 PATH，确保 ZI 存在于路径中
##############################################################################################################

## ZI Download
if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "${ZI[BIN_DIR]}" && command chmod go-rwX "${ZI[BIN_DIR]}"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "${ZI[BIN_DIR]}" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# ZI 启动！ :p
source "${ZI[BIN_DIR]}/zi.zsh"

# SOURCE 配置文件 需按顺序加载防止错误
[ ! -f  "${ZI[CONFIG_DIR]}/zi_complet.zsh"     ] ||  . "${ZI[CONFIG_DIR]}/zi_complet.zsh"
[ ! -f  "${ZI[CONFIG_DIR]}/zi_opt.zsh"         ] ||  . "${ZI[CONFIG_DIR]}/zi_opt.zsh"
[ ! -f  "${ZI[CONFIG_DIR]}/zi_plugin_load.zsh" ] ||  . "${ZI[CONFIG_DIR]}/zi_plugin_load.zsh"
[ ! -f  "${ZI[CONFIG_DIR]}/zi_plugin_conf.zsh" ] ||  . "${ZI[CONFIG_DIR]}/zi_plugin_conf.zsh"
