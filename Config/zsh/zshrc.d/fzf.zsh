# https://www.youtube.com/watch?v=qgG5Jhi_Els
# fzf export 
# Used finder
#   * fd
# OPTS
#
export FZF_DEFAULT_COMMAND='fd'

export FZF_DEFAULT_OPTS='--height 60% \
                          --layout=reverse-list \
                          --border --preview "echo {} | ~/.config/fzf/fzf_preview.py" \
                          --preview-window=right -m'
