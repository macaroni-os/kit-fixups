#!/bin/bash

process() {
  local f=$1

  v=$(curl https://discord.com/api/download?platform=linux | grep -E -o "https://.*.deb\"" | cut -d'/'  -f 6)
  echo "
vars:
  versions:
    - '${v}'
" > $f

  return 0
}

main() {
  local mode=$1
  local source_file=$2
  local target_file=$3

  case $mode in
    process)
      process "${target_file}" || return 1
      ;;

    *)
      echo "Unsupported mode ${mode}!"
      return 1
      ;;

  esac

  return 0
}

main $@
exit $?
