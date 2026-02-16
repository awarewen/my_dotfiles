
function nvims() {
  items=(
    "EchaVim"
    "LazyVim"
    "NvChad"
    #"default"
    #"SpaceVim"
    #"kickstart"
    #"RenChunHui_nvim"
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
alias nvimser="echavim --headless --listen localhost:7777"
alias nvide="env -u WAYLAND_DISPLAY neovide --multigrid --server=localhost:7777"

