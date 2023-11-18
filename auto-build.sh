#!/bin/bash

set -e

default_k8s_version="v1.27.8"
push="false"
cri="containerd"
platform="amd64"
debug="false"

for i in "$@"; do
  case $i in
  -c=* | --cri=*)
    cri="${i#*=}"
    if [ "$cri" != "docker" ] && [ "$cri" != "containerd" ]; then
      echo "Unsupported container runtime: ${cri}"
      exit 1
    fi
    shift # past argument=value
    ;;
  -n=* | --buildName=*)
    buildName="${i#*=}"
    shift # past argument=value
    ;;
  --platform=*)
    platform="${i#*=}"
    shift # past argument=value
    ;;
  --push)
    push="true"
    shift # past argument=value
    ;;
  -p=* | --password=*)
    password="${i#*=}"
    shift # past argument=value
    ;;
  -u=* | --username=*)
    username="${i#*=}"
    shift # past argument=value
    ;;
  --k8s-version=*)
    k8s_version="${i#*=}"
    shift # past argument=value
    ;;
  -h | --help)
    echo "
### Options
  --k8s-version         set the kubernetes k8s_version of the Clusterimage, k8s_version must be greater than 1.13,default: ${default_k8s_version}
  -c, --cri             cri can be set to docker or containerd,default: containerd
  -n, --buildName       set build image name, default is 'registry.cn-qingdao.aliyuncs.com/sealer-io/kubernetes:${k8s_version}'
  --platform            set the build mirror platform, the default is amd64, can be set to arm64
  --push                push clusterimage after building the clusterimage. The image name must contain the full name of the repository, and use -u and -p to specify the username and password.
  -u, --username        specify the user's username for pushing the Clusterimage
  -p, --password        specify the user's password for pushing the Clusterimage
  -d, --debug           show all script logs
  -h, --help            help for auto build shell scripts"
    exit 0
    ;;
  -d | --debug)
    debug="true"
    set -x
    shift
    ;;
  -*)
    echo "Unknown option $i"
    exit 1
    ;;
  *) ;;

  esac
done

if [[ $platform == "x86_64" || $platform == "amd64" ]]; then
    platform="amd64"
elif [[ $platform == "aarch64" || $platform == "arm64" ]]; then
    platform="arm64"
elif [[ $platform == "" ]]; then
    platform="amd64"
else
    echo "unsupported architecture $platform";
    exit 1;
fi

if [ "$k8s_version" = "" ]; then
  echo "not set kubernetes version,use default kubernetes version ${default_k8s_version}";
  k8s_version=default_k8s_version;
else
  echo "$k8s_version";
fi

echo "cri: ${cri}, kubernetes version: ${k8s_version},platform: ${platform}, build image name: ${buildName}"

workdir="context-${cri}-${platform}-${k8s_version}"
#检查workdir文件夹是否存在
if [ ! -d "${workdir}" ]; then
    echo "${workdir} not exists,check params";
    exit 1
fi

cd ${workdir};
#    编译
bash build.sh
#    下载sealer
wget https://github.com/tangxusc/sealer/releases/download/v0.11.1/sealer-v0.11.1-linux-${platform}.tar.gz && tar -xvf sealer-v0.11.1-linux-${platform}.tar.gz && rm -rf sealer-v0.11.1-linux-${platform}.tar.gz
./sealer build -t ${buildName} -f Kubefile
if [[ "${push}" == "true" ]]; then
  if [[ -n "$username" ]] && [[ -n "$password" ]]; then
    ./sealer login "$(echo "${buildName}" | awk -F/ '{print $1}')" -u "${username}" -p "${password}"
  fi
  ./sealer push ${buildName}
fi
if [[ "${debug}" == "true" ]]; then
  bash clean.sh
fi
rm -rf sealer


