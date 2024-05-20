#!/usr/bin/env bash

# 将ncm转换为mp3/flact
# 需要 ncmdump
# Usage: ./ncm_dump.sh [File_Path]

ls "$1" \
| while read -r line; do
    if [ "${line##*.}" == "ncm" ]; then
      echo "Covering:     $1/$line"
      ncmdump "$1/$line" || ncmdump_not_found
      rm "$1/$line"
    fi
  done

founction ncmdump_not_found {
  echo "Error: ncmdump not found."
  echo "Please install ncmdump!"
  exit 1
}
