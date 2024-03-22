build-amd64-v1.27.8:
	bash -x ./auto-build.sh -c=containerd --k8s-version=v1.27.8 --buildName=ccr.ccs.tencentyun.com/dlxx-platform/k8s:containerd-amd64-v1.27.8
