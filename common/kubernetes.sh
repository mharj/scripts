#!/bin/bash
BIN_PATH=/usr/local/bin
K8S_VERSION=$(curl -sS https://storage.googleapis.com/kubernetes-release/release/stable.txt)
case "$1" in 
  master)
    if [ "${2}" == "install" ]; then
      mkdir -p /etc/kubernetes/master;
      [ ! -f /etc/kubernetes/master/config.conf ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/etc/kubernetes/master/config.conf -O /etc/kubernetes/master/config.conf
    fi
    BINS="kube-apiserver kube-controller-manager kube-scheduler kubectl kube-proxy";
    ;;
  node) 
    if [ "${2}" == "install" ]; then
      mkdir -p /etc/kubernetes/node
    fi
    BINS="kubelet kubectl"
    ;;
  multi)
    if [ "${2}" == "install" ]; then
      mkdir -p /etc/kubernetes/master
      mkdir -p /etc/kubernetes/node
    fi
    BINS="kube-apiserver kube-controller-manager kube-scheduler kubectl kubelet kube-proxy";
    ;;
esac
case "$2" in 
  install)
    echo "${2} kubernetes ${1} (${K8S_VERSION})"
    for i in $BINS
    do
      wget -nv https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/$i --no-check-certificate -O ${BIN_PATH}/$i;
      case $i in 
        kube-apiserver)
          if [ -x /bin/systemctl ]; then
            wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/services/systemd/kube-apiserver.service -O /lib/systemd/system/kube-apiserver
          fi
#          if [ ! -f /etc/kubernetes/master/config.conf ]
          ;;
      esac
    done
    if [ -x /bin/systemctl ]; then
      systemctl daemon-reload
    fi
    ;;
  remove)
    echo "${2} kubernetes ${1} (${K8S_VERSION})"
    for i in $BINS
    do
      rm -v ${BIN_PATH}/$i; 
    done
    ;;
esac
