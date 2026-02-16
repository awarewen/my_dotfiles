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
  HISTSIZE=50000
  SAVEHIST=50000
setopt autocd extendedglob
bindkey -v

#                                                 zinit init                                                 #
##############################################################################################################
# ZI PATH SET
typeset -A ZI
  # HOME PATH
  ZI[HOME_DIR]="${HOME}/.local/share/zi"
  # BIN PATH
  ZI[BIN_DIR]="${ZI[HOME_DIR]}/zi/bin"
  # CONFIG PATH (zi && plugins)
  ZI[CONFIG_DIR]="${HOME}/.config/zsh/zi.d"

if [[ -f "${ZDOTDIR}/zi_init.zsh" ]]; then
  source "${ZDOTDIR}/zi_init.zsh"
fi


#                                             Source Zsh config                                            #
##############################################################################################################


#                                             Alias And Functions                                            #
##############################################################################################################

# Nvim alias and functions
alias lnvim="NVIM_APPNAME=lnvim nvim"
alias Snvim="NVIM_APPNAME=Snvim nvim"
alias knvim="NVIM_APPNAME=knvim nvim"
alias Gnvim="NVIM_APPNAME=glepnvim nvim"

set_proxy() { export https_proxy=http://127.0.0.1:$1 && export http_proxy=http://127.0.0.1:$1 && export all_proxy=127.0.0.1:$1; }
unset_proxy() { unset https_proxy && unset http_proxy && unset all_proxy; }

function nvims() {
  items=(
    #"knvim"
    "lnvim"
    #"SpaceVim"
  )
  NVIM_CONFIG=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout reverse --border --exit-0)
  if [[ -z $NVIM_CONFIG ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $NVIM_CONFIG == "default" ]]; then
    NVIM_CONFIG=""
  fi
  NVIM_APPNAME=$NVIM_CONFIG nvim $@
}
alias hx="helix ."

alias nvimser="nvim --headless --listen localhost:7777"
alias nvide="env -u WAYLAND_DISPLAY neovide --multigrid --server=localhost:7777"

alias gomusicfox='~/Downloads/Github/go-musicfox/bin/musicfox'


## PKGBUILD downloads
down_pkgbuild(){ git clone --branch $1 --single-branch https://github.com/archlinux/aur.git ./$1_PKGBUILD }

#                                       Export && PATH && Source                                             #
##############################################################################################################
##  zoxide fzf OPT
export _ZO_FZF_OPTS='--height 60% --layout reverse --border top --preview "echo {} | ~/.config/fzf/fzf_preview.py" --preview-window=right -m' # --layout=reverse-list 

## fzf OPT
export FZF_DEFAULT_COMMAND='fd --hidden --follow . /home/awarewen /etc /usr' #. /etc /home
#export FZF_DEFAULT_COMMAND='rg ' #. /etc /home
export FZF_DEFAULT_OPTS='--height 60% --layout reverse --border top --preview "echo {} | ~/.config/fzf/fzf_preview.py" --preview-window=right -m' # --layout=reverse-list 

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
alias FontsName="fc-query -f '%{fullname[0]}\n'"

alias yayw="sudo pacman -Sy && sudo powerpill -Su && paru -Su"

# 列出已安装的 pkg 包大小 https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#aria2
alias pacmanlist="LC_ALL=C pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h"

## Kitty SSH
## 使用kitty 提供的ssh
if [[ "$TERM" == "xterm-kitty" ]] then
  alias ssh="kitty +kitten ssh"
fi

# EDIOR .zshrc
alias Ezsh='nvim ${ZDOTDIR}/.zshrc'
alias ff='fastfetch -c ~/.config/fastfetch/config_1.jsonc'

# cargo PATH
  export PATH="$HOME/.cargo/bin:$PATH"

# clear rubish
function Cpacman () {
  s pacman -Scc --noconfirm
  yay -Scc --noconfirm
  s pacman -Rns $(pacman -Qtdq)
  echo "Done !"
}

alias cls="printf '\033[2J\033[3J\033[1;1H'"
alias qq="linuxqq --ozone-platform-hint=auto --enable-wayland-ime"

export EDITOR=nvim
#wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator
rfv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            vim {1} +{2}     # No selection. Open the current line in Vim.
          else
            vim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)


PATH="/home/awarewen/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/awarewen/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/awarewen/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/awarewen/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/awarewen/perl5"; export PERL_MM_OPT;

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# eudic run dep path
#export LD_LIBRARY_PATH="/usr/local/lib"
#export QT_PLUGIN_PATH="/usr/lib/qt/plugins"
#export GST_PLUGIN_PATH="/usr/lib/gstreamer-1.0"
#export GST_PLUGIN_SYSTEM_PATH="/lib/gstreamer-1.0"
# pnpm
export PNPM_HOME="/home/awarewen/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# npm globle path
export PATH="$(npm prefix -g)/bin:$PATH"

# OpenClaw Completion
source "/home/awarewen/.openclaw/completions/openclaw.zsh"

# Added by Qoder CLI installer
export PATH="$PATH:/home/awarewen/.local/bin"

# upgrade illogical-impulse 
alias upgradebar="cd ~/.cache/dots-hyprland && git stash && git pull && ./setup install"

# x-cmd
[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

# dotfiles 备份：backup 命令（试运行），backup --run 执行同步
[[ -f "${ZDOTDIR}/zshrc.d/dot_backup.zsh" ]] && source "${ZDOTDIR}/zshrc.d/dot_backup.zsh"
