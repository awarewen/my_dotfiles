gfile (){
  if ! sudo tailscale file get $@; then
    return 0
  fi
    return 1
}

sfile (){
  if ! sudo tailscale file cp $1 "$2:"; then
    return 0
  fi
    return 1
}
