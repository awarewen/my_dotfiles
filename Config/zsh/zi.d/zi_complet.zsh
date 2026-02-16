# ZI load
# ============================================


# completion init
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi
