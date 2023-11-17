#!/usr/bin/env bash
set -x

source version.sh

gperf_url="https://ftp.gnu.org/gnu/gperf"
gperf_tarball="gperf-${gperf_version:-}.tar.gz"
gperf_tarball_url="${gperf_url}/${gperf_tarball}"

libseccomp_url="https://github.com/seccomp/libseccomp"
libseccomp_tarball="libseccomp-${libseccomp_version:-}.tar.gz"
libseccomp_tarball_url="${libseccomp_url}/releases/download/v${libseccomp_version}/${libseccomp_tarball}"

nerdctl_url="https://github.com/containerd/nerdctl"
nerdctl_tarball_amd64="nerdctl-${nerdctl_version:-}-linux-amd64.tar.gz"
nerdctl_tarball_amd64_url="${nerdctl_url}/releases/download/v${nerdctl_version}/${nerdctl_tarball_amd64}"

seautil_url="https://github.com/sealerio/sealer"
seautil_tarball_amd64="seautil-v${seautil_version:-}-linux-amd64.tar.gz"
seautil_tarball_amd64_url="${seautil_url}/releases/download/v${seautil_version}/${seautil_tarball_amd64}"

crictl_url="https://github.com/kubernetes-sigs/cri-tools"
crictl_tarball_amd64="crictl-v${crictl_version:-}-linux-amd64.tar.gz"
crictl_tarball_amd64_url="${crictl_url}/releases/download/v${crictl_version}/${crictl_tarball_amd64}"

install_url="https://sealer.oss-cn-beijing.aliyuncs.com/auto-build"

containerd_url="https://github.com/containerd/containerd"
cri_tarball_amd64="cri-containerd-${containerd_version:-}-linux-amd64.tar.gz"
cri_tarball_amd64_url="${containerd_url}/releases/download/v${containerd_version}/${cri_tarball_amd64}"
registry_tarball_amd64="nerdctl-amd64-registry-image.tar.gz"
echo "download containerd version ${containerd_version} ,url ${cri_tarball_amd64_url}"

registry_tarball_amd64_url="${install_url}/${registry_tarball_amd64}"
echo "download registry tarball ${registry_tarball_amd64_url}"

mkdir -p cri bin images rootfs/manifests

wget "${install_url}/linux-amd64/conntrack-${conntrack_version:-}/bin/conntrack" && mv conntrack "bin"

echo "download gperf version ${gperf_version}"
mkdir -p "rootfs/lib"
curl -sLO "${gperf_tarball_url}" && mv "${gperf_tarball}" "rootfs/lib"

echo "download libseccomp version ${libseccomp_version}"
curl -sLO "${libseccomp_tarball_url}" && mv "${libseccomp_tarball}" "rootfs/lib"

echo "download nerdctl version ${nerdctl_version}"
wget -q "${nerdctl_tarball_amd64_url}" && tar zxvf "${nerdctl_tarball_amd64}" -C "bin" && rm ${nerdctl_tarball_amd64}

echo "download crictl version ${crictl_version}"
wget -q "${crictl_tarball_amd64_url}" && tar zxvf "${crictl_tarball_amd64}" -C "bin" && rm ${crictl_tarball_amd64}

echo "download seautil version ${seautil_version}"
wget -q "${seautil_tarball_amd64_url}" && tar zxvf "${seautil_tarball_amd64}" -C "bin" && rm ${seautil_tarball_amd64}

echo "download cri with containerd version ${containerd_version}"
wget -q "${cri_tarball_amd64_url}" && mv "${cri_tarball_amd64}" "cri/cri.tar.gz"

echo "download distribution image ${registry_tarball_amd64}"
wget -q "${registry_tarball_amd64_url}" && mv "${registry_tarball_amd64}" "images"

echo "download kubeadm kubectl kubelet version ${kube_install_version}"

for i in "kubeadm" "kubectl" "kubelet"; do
  echo "download ${i} version ${kube_install_version} for amd64"
  curl -L "https://dl.k8s.io/release/${kube_install_version}/bin/linux/amd64/${i}" -o "bin/${i}"
done

chmod +x bin/*