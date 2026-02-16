# zoxide history jump view with fzf options
#
export _ZO_FZF_OPTS='--height 60% \
                      --border top\
                      --layout reverse \
                      --preview "echo {} | ~/.config/fzf/fzf_preview.py" \
                      --preview-window=right \
                      -m'
