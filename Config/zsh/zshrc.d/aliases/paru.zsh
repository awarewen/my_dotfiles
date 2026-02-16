# pkg manager
alias yay='paru'

# PKG Search
alias yays="paru -Slq | fzf --multi --preview 'paru -Si {1}' | xargs -ro paru -S"

# PKG Remove
alias yayr="paru -Qq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
