# ZI load
# ============================================

source "${ZI[BIN_DIR]}/zi.zsh"    # ## LOAD ZI

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

