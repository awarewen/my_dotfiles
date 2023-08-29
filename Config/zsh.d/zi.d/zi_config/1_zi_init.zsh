##############################################################################################################
#
#                                                   ZI
#  ZI[HOME_DIR]="${HOME}/.zi"
#  ZI[BIN_DIR]="${HOME}/.zi/bin"
#  ZI[CONFIG_DIR]="${HOME}/.config/zsh.d/zi.d"
#  -- 如果本地没有下载zi,将会自动下载
##############################################################################################################

# ZI XDG PATH SET
typeset -A ZI
  ## 将 zi home_dir 转移到 `${HOME}/.config/zsh.d/zi.d/zi` 与 `zsh` 一起进行管理
  ZI[HOME_DIR]="${HOME}/.config/zsh.d/zi.d/zi"
  ZI[BIN_DIR]="${ZI[HOME_DIR]}/zi/bin"
  ## 此处将配置文件独立出来，方便配置转移
  ZI[CONFIG_DIR]="${HOME}/.config/zsh.d/zi.d/zi_config"

## ZI Download
if [[ ! -f ${ZI[BIN_DIR]}/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "${ZI[BIN_DIR]}" && command chmod go-rwX "${ZI[BIN_DIR]}"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "${ZI[BIN_DIR]}" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
