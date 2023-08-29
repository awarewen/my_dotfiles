# zsh-vi-mode : 命令行 vi 模式
# ## https://github.com/jeffreytse/zsh-vi-mode
# =========================================
ZVM_CURSOR_STYLE_ENABLED=true     # 光标样式开关
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk   # 回退到 Normal 模式快捷键
ZVM_VI_SURROUND_BINDKEY=s-prefix  # 环绕模式 (classic / s-prefix)
ZVM_KEYTIMEOUT=0.5                # 按键等待时间
# =========================================

# H-S-MW : 历史命令搜索
# ## https://github.com/z-shell/H-S-MW
# =========================================
zstyle :plugin:history-search-multi-word reset-prompt-protect 1        # 查看命令的所有匹配项以及周围的命令集
typeset -gA HSMW_HIGHLIGHT_STYLES
HSMW_HIGHLIGHT_STYLES[path]="bg=magenta,fg=white,bold"                 # 通过 `HSMW_HIGHLIGHT_STYLES` 设定关联数组进行自定义语法高亮 "完整列表: https://github.com/z-shell/H-S-MW/blob/main/functions/hsmw-highlight#L36-L65"
zstyle ":history-search-multi-word" page-size "8"                      # 显示条目数量 (default is $LINES/3)
zstyle ":history-search-multi-word" highlight-color "fg=red,bold"      # 突出显示匹配搜索文本的颜色 (default bg=17 on 256-color terminals)
zstyle ":plugin:history-search-multi-word" synhl "yes"                 # 是否进行语法高亮 (default true)
zstyle ":plugin:history-search-multi-word" active "underline"          # 对活动历史记录条目的影响 Try: standout, bold, bg=blue (default underline)
zstyle ":plugin:history-search-multi-word" check-paths "yes"           # 是否使用 magenta 颜色标记搜索列表中在当前目录下存在的目录路径 (default true)
zstyle ":plugin:history-search-multi-word" clear-on-cancel "no"        # 使用 Ctrl-C or ESC 是否清除当前输入的查询
# =========================================

# 调整 F-sy-H zsh-completions zsh-autosuggestions 的加载顺序
zi wait lucid for \
  atinit"ZI[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
     z-shell/F-Sy-H \
  blockf \
      zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
     zsh-users/zsh-autosuggestions


zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'


zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' rehash true
