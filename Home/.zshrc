##############################################################################################################
#                                                           ▄
#                                                         J▓╫▓
#                                              ,,»∞*ª"""²▓╫▓╫▓
#                                          ,═ª`         ª▓▓▓╫▓ `═,
#                                -▓@▄µ  ,^`          ~      -     ╨w
#                                 ▓▓▓▓╩`               *,     ª,    ╙µ▄µ
#                                  ▀ÑÖ                  `V     `N  `,▓╫╫▓µ
#                                   ▒                    :╨µ     ╨µ~▓"╙"`▐Q
#                                 ,@▒       ░       ¿.`u  ░╨µ     ╨µ ▀▀╨▓▀ `v
#                                ▄╫ÑH.     ▒▒▒▒     ╫å  jµ∞░╫      ╫  ╫M"    ╘
#                               ▐▄,HH░ .   ▒░▒▒▒µ   JÑⁿ` `*ª╨N     `N'j   1µ  ╫
#                               ∩▀▓HÑ░ `▒╦▄╫▄ ╙╩╨▀ªª".¿]▄▄▄▄▄▓      ╫ ▐⌂  ▒╛╙µJµ
#                              h  ²µ▐⌂«ª",,╦≥µ        "╨▀▓▒▓`╩      ╫ JH æÖ  ²╩
#                             ╩ .  b  "╫▀▀▀▀▒▓▄         ▌╩░▌ ╩      ╫ ▐M╙ ]
#                             H å  $   ª▒  ╫▒▒▓          `└ Æφ      ╫     ╫
#                             ╘Ä ╙µ²µ  `úµ  ``         ¿ ,æ╜`1     .▌     j
#                                  `$   `▓╨⌐        -ªª     ,Ñ      ▒     J
#                                    φ   ╨µ             ,╓A▓▒H ░  ,K▄p     b
#                                     µ   ²▒@N╦╥╓,,,,«m▒░░░▓▓ ▒░ ,▀╫╫╨%µ   ▓
#                                     `µ  ░▒▒╫▒▒▒▄Å▀▓░░░░░▐▓U▒▒░╥▀ ▒▓      ╫      ╓▄▓▄
#                                      Kj `░▒▒▓▀▒"`▐▌░░░░▄╫Ö▒▒░4▄▄▓▓Ñ      JµΦ▓▓▓▓▓▓▓▓█▄
#                                     .╛)ªµ"░▒▒▓    ▀▄╦▄Æ▄▒▒▓▄▓▀▒▓▓▓        ▌  ▀╙└╙▀▀▓▓▓▓▓▄,
#                              ▄██▓▄▄µ` H  ╫▓╫Å╫▓∞%,░╫▄╩░▄▓▀▓╫▓▓▓╫▓  ▄▌     └µ       `   `"▀▀▓┐
#                            ▄███▓▀ `  ñ ╒ j▓▓▓Ñ╥$╨,▐▓▓█▀╫▒▒▓▓▓╫▓▀,▄▓╫▓µ▐H,  ╫
#                          ^╨         ñ,A▄▓"▓▀▓▓▓▐▄M─▄▀▀▓▓▒╫╫▓▓▓▓▓╫▓▓▓▓▌µW ªv,▀
#                                   ,Ñ╨ ▄Ñ╫▓▓▓ `└   *╜:╫ "╫▓▓▓╫▓▓▓▓▓▓▓▓▌ ╩,   ª▀
#                                     ,▓╫▓▓▓▓▓╫▓╦µ,  .░▓   ╙▀▓▓▓▓▓▓▓▓▓▓▌
#                                    J▓▓▓▓▓▓▓▓▓▌▒▓░▒▒w▄H   :░░▀▓▓▓▓▓▓▓▓█
#                                   ▄▌▓▓▓╫▓▓▓▓▓▓▒▌░░░░▓     ░▒▒▒╫▓▓▓▓╫▓█
#                                  *▀╜╜╜╜▀▀╜╜╜╜╜╜▀ºººº┘     "ª╨╨╜╜╜▀╜▀╜▀
#                                                   @Aware-wen
#                                                       .
#                                                      / \
#                                        #            /   \          | *
#                          a##e #%" a#"e 6##%        /^.   \       | | |-^-. |   | \ /
#                         .oOo# #   #    #  #       /  .-.  \      | | |   | |   |  X
#                         %OoO# #   %#e" #  #      /  (   ) _\     | | |   | ^._.| / \         TM
#                                                 / _.~   ~._^\
#                                                /.^         ^.\
#
##############################################################################################################


#                                                  PowerLevel10K                                             #
##############################################################################################################

#typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#                                                 ZSH Options                                                #
##############################################################################################################

HISTFILE=${HOME}/.histfile
if [[ -f ${HOME}/.zshhistfile || ! -f $HISTFILE ]]; then
  command touch $HISTFILE
fi
  HISTSIZE=10000
  SAVEHIST=10000
setopt autocd extendedglob
bindkey -v

#                                                 Load zinit                                                 #
##############################################################################################################

ZI_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config/zsh.d/zi.d/zi_config}
for file in ${ZI_CONFIG}/**/*(.N)
do
    [ -x "$file" ] &&  . "$file"
done

#                                             Alias And Functions                                            #
##############################################################################################################

# Nvim alias and functions
alias lnvim="NVIM_APPNAME=lnvim nvim"
alias knvim="NVIM_APPNAME=knvim nvim"
alias gnvim="NVIM_APPNAME=gnvim nvim"
alias ggnvim="NVIM_APPNAME=ggnvim nvim"


set_proxy() { export https_proxy=http://127.0.0.1:$1 && export http_proxy=http://127.0.0.1:$1 && export all_proxy=127.0.0.1:$1; }
unset_proxy() { unset https_proxy && unset http_proxy && unset all_proxy; }

function nvims() {
  items=(
    "knvim"
    "lnvim"
    #"SpaceVim"
  )
  NVIM_CONFIG=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $NVIM_CONFIG ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $NVIM_CONFIG == "default" ]]; then
    NVIM_CONFIG=""
  fi
  NVIM_APPNAME=$NVIM_CONFIG nvim $@
}
alias nvimser="nvim --headless --listen localhost:7777"
alias nvide="env -u WAYLAND_DISPLAY neovide --multigrid --server=localhost:7777"

alias gomusicfox='~/Downloads/Github/go-musicfox/bin/musicfox'


## PKGBUILD downloads
down_pkgbuild(){ git clone --branch $1 --single-branch https://github.com/archlinux/aur.git ./$1_PKGBUILD }

#                                       Export && PATH && Source                                             #
##############################################################################################################
##  zoxide fzf OPT
export _ZO_FZF_OPTS='--height 60% --layout=reverse-list --border --preview "echo {} | ~/.config/fzf/fzf_preview.py" --preview-window=right -m'

## fzf OPT
export FZF_DEFAULT_COMMAND='fd --hidden --follow . /home/awarewen /etc /usr' #. /etc /home
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse-list --border --preview "echo {} | ~/.config/fzf/fzf_preview.py" --preview-window=right -m'

alias l='eza -a'
alias ls='eza -alhG'
alias ll='eza -lhiogab --icons --group-directories-first'
alias lls='eza -lhioGgab --icons --group-directories-first'
alias lll='eza -lhiogab --icons'
alias llls='eza -lhioGgab --icons'
alias ld='eza -liogab --icons -D'
alias lds='eza -lioGgab --icons -D'
alias lf='eza -liogab --icons -f'
alias lfs='eza -lioGgab --icons -f'

alias s='sudo'
alias yays="paru -Slq | fzf --multi --preview 'paru -Si {1}' | xargs -ro paru -S"
alias yayr="paru -Qq | fzf --multi --preview 'paru -Qi {1}' | xargs -ro paru -Rns"
alias yay='paru'
# Tailscale
alias gfile='sudo tailscale file get'
alias sfile='sudo tailscale file cp'

alias cdme='cd ~/Documents/'

# fzf
alias Efzf='nvims "$(fzf)"'

# start app go-musicfox
alias gomusicfox='~/Downloads/Github/go-musicfox/bin/musicfox'

# fars
alias fars='curl -F "c=@-" "https://fars.ee"'

# mpv play list
alias mpvl='mpv --player-operation-mode=pseudo-gui'

# 查看字体的 family name
alias FontsFamilyName="fc-query -f '%{family[0]}\n'"

alias yayw="sudo pacman -Sy && sudo powerpill -Su && paru -Su"

# 列出已安装的 pkg 包大小 https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#aria2
alias pacmanlist="LC_ALL=C pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h"

## Kitty SSH
## 使用kitty 提供的ssh
if [[ "$TERM" == "xterm-kitty" ]] then
  alias ssh="kitty +kitten ssh"
fi

# EDIOR .zshrc
alias Ezsh='nvim ~/.zshrc'
alias ff='fastfetch -c ~/.config/fastfetch/config_1.jsonc'
