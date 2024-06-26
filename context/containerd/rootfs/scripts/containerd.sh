#!/bin/bash

set -x
set -e

scripts_path=$(cd `dirname "$0"`; pwd)
image_dir="${scripts_path}/../images"
dump_config_dir="${scripts_path}/../etc/dump-config.toml"
containerd_tar="${scripts_path}/../cri/cri-containerd.tar.gz"
nerdctl_path="${scripts_path}/../bin/nerdctl"

source "${scripts_path}"/common.sh

if ! command_exists containerd; then
  tar zxvf ${containerd_tar} -C /
fi

if ! command_exists nerdctl; then
  cp ${nerdctl_path} /usr/bin/nerdctl
  cp ${nerdctl_path} /usr/bin/docker
fi

sed -i "s/sea.hub/${2:-sea.hub}/g" "$dump_config_dir"
sed -i "s/5000/${3:-5000}/g" "$dump_config_dir"

mkdir -p /etc/containerd
containerd --config "$dump_config_dir" config dump >/etc/containerd/config.toml
disable_selinux
systemctl daemon-reload
systemctl enable containerd.service
systemctl restart containerd.service
load_image_server="nerdctl"

server_load_images "${load_image_server}" "${image_dir}"