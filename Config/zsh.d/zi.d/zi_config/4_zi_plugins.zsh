##############################################################################################################
#                                                                                                            #
#                                                Load Plugins                                                #
# plagin list:
# Use meta-plugins to install common annexes as a group:
# =====================================================
# - z-shell/z-a-meta-plugins
#   - @annexes+           :bin-gem-node, readurl, patch-dl, rust, default-ice, unscope, ++ submods, test
#   - @zsh-users+fast     :F-Sy-H, zsh-autosuggestions, zsh-completions, zsh-fancy-completions
#   - @fuzzy              :fzf(PKG), fzy(PKG), skim, peco
#   - @romkatv            :powerlevel10k
#   - @console-tools      :dircolors-material(PKG), fd, bat, hexyl, hyperfine, vivid, exa, ripgrep, tig
#   - @zunit
# =====================================================
# - jeffreytse/zsh-vi-mode # zsh vi 模式
# - z-shell/H-S-MW         # 替换 ~cantino/mcfly~ ## 历史命令搜索
# - z-shell/zsh-zoxide     # 历史路径跳转
# - z-shell/zi-console     # zi 文本界面控制面板
# - z-shell/curses         #
# - z-shell/zui            # zui 文本界面库
# - zsh-users/zsh          # zsh
# =====================================================

# meta Plugins
# ## https://wiki.zshell.dev/zh-Hans/ecosystem/annexes/meta-plugins
# zi 中受到支持的多数插件以关联的实用工具链的形式成组提供 meta 包
# =====================================================
zi light-mode for \
  z-shell/z-a-meta-plugins \
  @annexes+ \
  @zsh-users+fast \
  @fuzzy \
  @romkatv \
  @zunit \
  @console-tools

# zsh-vi-mode
# ## https://github.com/jeffreytse/zsh-vi-mode
zi ice depth=1;zi light jeffreytse/zsh-vi-mode     # ## zsh-vi-mode

# zoxide
zi has'zoxide' wait lucid for z-shell/zsh-zoxide   # ## 需要 zoxide 二进制文件, 如果存在则加载

#  H-S-MW
# ## https://github.com/z-shell/H-S-MW
zi ice wait lucid; zi light z-shell/H-S-MW

# zi-console
# https://wiki.zshell.dev/zh-Hans/ecosystem/plugins/zi-console
# =====================================================
zi wait lucid for z-shell/zi-console
# zi-console 依赖于 curses， 构建 zsh/curses 模块
zi ice id-as"zsh" atclone"./.preconfig
    CFLAGS='-I/usr/include -I/usr/local/include -g -O2 -Wall' \
    LDFLAGS='-L/usr/lib -L/usr/local/lib' ./configure --prefix='$ZPFX'" \
  atpull"%atclone" run-atpull make"install" pick"/dev/null"
zi load zsh-users/zsh
# ZUI 文本界面库
zi load z-shell/zui
