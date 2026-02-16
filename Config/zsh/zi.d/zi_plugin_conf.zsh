# zsh-vi-mode : 命令行 vi 模式
# ## https://github.com/jeffreytse/zsh-vi-mode
# =========================================
ZVM_CURSOR_STYLE_ENABLED=true     # 光标样式开关
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk   # 回退到 Normal 模式快捷键
ZVM_VI_SURROUND_BINDKEY=s-prefix  # 环绕模式 (classic / s-prefix)
ZVM_KEYTIMEOUT=0.5                # 按键等待时间
ZVM_SYSTEM_CLIPBOARD_ENABLED=true # 使用系统剪切板
# =========================================

# H-S-MW : 历史命令搜索
# ## https://github.com/z-shell/H-S-MW
# =========================================
zstyle :plugin:history-search-multi-word reset-prompt-protect 1        # 查看命令的所有匹配项以及周围的命令集
typeset -gA HSMW_HIGHLIGHT_STYLES
HSMW_HIGHLIGHT_STYLES[path]="bg=magenta,fg=white,bold"                 # 通过 `HSMW_HIGHLIGHT_STYLES` 设定关联数组进行自定义语法高亮 "完整列表: https://github.com/z-shell/H-S-MW/blob/main/functions/hsmw-highlight#L36-L65"
zstyle ":history-search-multi-word" page-size "10"                     # 显示条目数量 (default is $LINES/3)
zstyle ":history-search-multi-word" highlight-color "fg=red,bold"      # 突出显示匹配搜索文本的颜色 (default bg=17 on 256-color terminals)
zstyle ":plugin:history-search-multi-word" synhl "yes"                 # 是否进行语法高亮 (default true)
zstyle ":plugin:history-search-multi-word" active "underline"          # 对活动历史记录条目的影响 Try: standout, bold, bg=blue (default underline)
zstyle ":plugin:history-search-multi-word" check-paths "yes"           # 是否使用 magenta 颜色标记搜索列表中在当前目录下存在的目录路径 (default true)
zstyle ":plugin:history-search-multi-word" clear-on-cancel "no"        # 使用 Ctrl-C or ESC 是否清除当前输入的查询
# =========================================
