##  zoxide fzf OPT
export _ZO_FZF_OPTS='--height 60% --layout=reverse-list --border --preview "echo {} | ~/.config/fzf/fzf_preview.py" --preview-window=right -m'

## fzf OPT
export FZF_DEFAULT_COMMAND='fd --hidden --follow . /home/awarewen /etc /usr' #. /etc /home
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse-list --border --preview "echo {} | ~/.config/fzf/fzf_preview.py" --preview-window=right -m'
