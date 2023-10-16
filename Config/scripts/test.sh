#! /bin/bash

declare -a ARRAY=('( ^-^)/' '( .-.)/' '( U-U)/' '\ (•◡•) /' '(づ￣ ³￣)づ');
declare -a COLOR=("\e[0;31m" "\e[0;32m" "\e[0;33m" "\e[0;34m" "\e[0;35m" "\e[0;36m");

randomEmoji() {
  arr=("${!1}");
  color=("${!2}");
  printf "${color["$[RANDOM % ${#color[@]}]"]}${arr["$[RANDOM % ${#arr[@]}]"]}\x1b[0m\n\n";
}

randomEmoji "ARRAY[@]" "COLOR[@]";
