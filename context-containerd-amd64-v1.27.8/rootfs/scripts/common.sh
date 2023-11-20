#!/bin/bash

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

#参照 https://github.com/nextcloud/all-in-one/discussions/1970
setMaximumBufferSize(){
#  echo "net.core.rmem_max = 2500000" | sudo tee /etc/sysctl.d/nextcloud-aio-buffer-increase.conf
  echo "net.core.rmem_max = 2500000" | tee /etc/sysctl.d/nextcloud-aio-buffer-increase.conf
  sysctl "net.core.rmem_max=2500000"
  sysctl -p
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

copy_bins() {
  chmod -R 755 "${1}"/../bin/*
  chmod 644 "${1}"/../bin
  cp "${1}"/../bin/* /usr/bin
  cp "${1}"/../scripts/kubelet-pre-start.sh /usr/bin
  chmod +x /usr/bin/kubelet-pre-start.sh
}
