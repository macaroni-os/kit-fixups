#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org
# Description: custom generator script that use google JSON
#              to retrieve last available version.
#
# This script is called as: chrome.sh process <source_vars_file> <target_vars_file>

apihost="https://chromiumdash.appspot.com"


process() {
  local f=$1

  local url="${apihost}/fetch_releases?channel=${channel}&platform=Linux&num=1"
  # Read the last version from Google server.
  local v=$(curl "${url}" | jq .[0].version -r)

  echo "
vars:
  versions:
    - '${v}'
" > $f

  echo $v
}


read_vars() {
  local f=$1
  #cat $f
  # Read atom information
  local name=$(yq4 e '.name' $f)
  local category=$(yq4 e '.atom.category' $f)
  channel=$(yq4 e '.atom.vars.channel' $f)

  echo "Elaborating package ${name} of category ${category} for channel ${channel}..."

  export name category channel

  return 0
}

main() {
  local mode=$1
  local source_file=$2
  local target_file=$3

  case $mode in
    process)
      read_vars "${source_file}" || return 1
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
