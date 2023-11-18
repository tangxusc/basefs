#!/bin/bash

set -x
set -e

scripts_path=$(cd `dirname "$0"`; pwd)
image_dir="${scripts_path}/../images"
dump_config_dir="${scripts_path}/../etc/dump-config.toml"
host_config_dir="${scripts_path}/../etc/hosts.toml"
containerd_tar="${scripts_path}/../cri/cri.tar.gz"
nerdctl_path="${scripts_path}/../bin/nerdctl"

source "${scripts_path}"/common.sh

copy_bins "${scripts_path}"

if ! command_exists containerd; then
  tar zxvf ${containerd_tar} -C /
fi

if ! command_exists nerdctl; then
  cp ${nerdctl_path} /usr/bin/nerdctl
  cp ${nerdctl_path} /usr/bin/docker
fi

sed -i "s/sea.hub/${2:-sea.hub}/g" "$dump_config_dir"
sed -i "s/5000/${3:-5000}/g" "$dump_config_dir"

mkdir -p /etc/containerd /etc/containerd/certs.d/_default
containerd --config "$dump_config_dir" config dump >/etc/containerd/config.toml
cp ${host_config_dir} /etc/containerd/certs.d/_default/hosts.toml
setMaximumBufferSize
disable_selinux
systemctl daemon-reload
systemctl enable containerd.service
systemctl restart containerd.service
load_image_server="nerdctl"

server_load_images "${load_image_server}" "${image_dir}"