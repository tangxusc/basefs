#!/bin/bash

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

disable_selinux() {
  if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
  fi
  if ! getenforce | grep Disabled;then
    setenforce 0 || true
  fi
}

get_distribution() {
  lsb_dist=""
  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi
  return lsb_dist
}

server_load_images() {
  for image in ${2}/*; do
    if [ -f "${image}" ]; then
      ${1} load -i "${image}"
    fi
  done
}
