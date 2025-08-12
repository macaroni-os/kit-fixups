#!/bin/bash

process() {
  local f=$1

  v=$(curl https://zoom.us/client/latest/zoom_x86_64.pkg.tar.xz  -i | grep ^location | awk '{ print $2 }' | grep -E -o '/[0-9.]+/' | cut -d'/' -f 2)
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
