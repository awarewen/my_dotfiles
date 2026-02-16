##############################################################################################################
#                                                                                                            #
#                                                Load Plugins                                                #
# > 此文件仅存放插件下载以及加载的必要条件，插件配置文件为: 5_zi_plugins_conf.zsh
# plagin list:
# Use meta-plugins to install common annexes as a group:
# =====================================================
# - z-shell/z-a-meta-plugins
#   - @annexes+           :bin-gem-node, readurl, patch-dl, rust, default-ice, unscope, ++ submods, test
#   - @zsh-users+fast     :F-Sy-H, zsh-autosuggestions, zsh-completions, zsh-fancy-completions
#   - @fuzzy              :fzf(PKG), fzy(PKG), skim, peco
#   - @romkatv            :powerlevel10k
#   - @console-tools      :dircolors-material(PKG), fd, bat, hexyl, hyperfine, vivid, exa, ripgrep, tig
# =====================================================
# - jeffreytse/zsh-vi-mode # zsh vi 模式
# - z-shell/H-S-MW         # 替换 ~cantino/mcfly~ ## 历史命令搜索
# - z-shell/zsh-zoxide     # 历史路径跳转
# - z-shell/zi-console     # zi 文本界面控制面板
# - z-shell/curses         #
# - z-shell/zui            # zui 文本界面库
# - zsh-users/zsh          # zsh
# - Freed-Wu/fzf-tab-source # fzf-tab-source
# - eza-community/eza      # ls 的现代替代品
# - zsh-shell/zsh-eza
# =====================================================

# meta Plugins
# ## https://wiki.zshell.dev/zh-Hans/ecosystem/annexes/meta-plugins
# zi 中受到支持的多数插件以关联的实用工具链的形式成组提供 meta 包
# =====================================================
zi light-mode for \
  z-shell/z-a-meta-plugins \
          @annexes+ \
          @zsh-users+fast \
          skip'skim peco' @fuzzy \
          @romkatv \
          skip'exa vivid hyperfine hexyl dircolors-material' @console-tools \
# =====================================================

# zsh-vi-mode
# ## https://github.com/jeffreytse/zsh-vi-mode
# =====================================================
zi ice depth=1 
zi light jeffreytse/zsh-vi-mode
# =====================================================

# Zoxide
# =====================================================
zi ice wait lucid as'null' from"gh-r" sbin
zi light ajeetdsouza/zoxide

zi ice wait lucid has'zoxide' atinit="_ZO_CMD_PREFIX=c _ZO_FZF_OPTS='--height 40% --layout=reverse-list --border'"
zi light z-shell/zsh-zoxide
# =====================================================

# H-S-MW
# ## https://github.com/z-shell/H-S-MW
# =====================================================
zi ice wait lucid
zi light z-shell/H-S-MW
# =====================================================

# zi-console
# https://wiki.zshell.dev/zh-Hans/ecosystem/plugins/zi-console
# =====================================================
# 加载顺序 zui -> zi-console
zi ice wait lucid for \
  z-shell/zui \
  z-shell/zi-console
# zi-console 依赖于 curses， 构建 zsh/curses 模块
#zi ice id-as"zsh" atclone"./.preconfig
#    CFLAGS='-I/usr/include -I/usr/local/include -g -O2 -Wall' \
#    LDFLAGS='-L/usr/lib -L/usr/local/lib' ./configure --prefix='$ZPFX'" \
#  atpull"%atclone" run-atpull make"install" pick"/dev/null"
#zi load zsh-users/zsh
# ZUI 文本界面库，zi-console 依赖
# =====================================================

# fzf-tab-source
zi ice wait lucid 
zi light Freed-Wu/fzf-tab-source

# eza
zi ice wait lucid from'gh' as'program' sbin'**/eza -> eza' atclone'CARGO_HOME=$ZPFX cargo install --path . && cp -vf completions/zsh/_eza _eza'
zi light eza-community/eza

zi ice wait lucid has'eza' atinit'AUTOCD=1'
zi light z-shell/zsh-eza
