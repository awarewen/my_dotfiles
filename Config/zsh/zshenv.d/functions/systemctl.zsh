systart (){
  if ! systemctl start $@ --now; then
    return 0
  fi
    return 1
}

systop (){
  if ! systemctl stop $@ --now; then
    return 0
  fi
    return 1
}

systatus (){
  if ! systemtl status $@; then
    return 0
  fi
    return 1
}
