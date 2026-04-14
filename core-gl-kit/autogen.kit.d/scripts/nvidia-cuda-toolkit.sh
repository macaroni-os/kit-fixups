#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org
# Description: This script is used to parse the JSON file and recover
#              the version of the NVIDIA driver used to create the
#              download url.


read_vars() {
  local f=$1

  baseurl=$(yq4 e '.vars.base_url' $f)
  version=$(yq4 e '.vars.version' $f)
  name=$(yq4 e '.name' $f)

  export baseurl version name
  return 0
}

process() {
  local f=$1
  local nvidia_driver=$(curl "${baseurl}version_${version}.json" | jq .nvidia_driver.version -r)

  echo "For url ${baseurl}version_${version}.json found NVIDIA Driver ${nvidia_driver}"
  if [ -z "${nvidia_driver}" ] ; then
    echo "Error on retrieve nvidia driver"
    return 1
  fi

  echo "
vars:
  nvidia_driver: ${nvidia_driver}
artefacts:
  - name: '${name}-${version}_${nvidia_driver}_linux_x86_64.run'
    url: 'https://developer.download.nvidia.com/compute/cuda/${version}/local_installers/cuda_${version}_${nvidia_driver}_linux.run'
    use: amd64
  - name: '${name}-${version}_${nvidia_driver}_linux_arm64.run'
    url: 'https://developer.download.nvidia.com/compute/cuda/${version}/local_installers/cuda_${version}_${nvidia_driver}_linux_sbsa.run'
    use: arm64
" > $f

  echo "Write file $f"

  return 0
}

main() {
  local source_file=$1
  local target_file=$2

  read_vars "${source_file}" || return 1
  process "${target_file}" || return 1

  return 0
}

main $@
exit $?
