#!/bin/bash
BIN_PATH=/usr/local/bin
K8S_VERSION=$(curl -sS https://storage.googleapis.com/kubernetes-release/release/stable.txt)
case "$1" in 
  master)
    BINS="kube-apiserver kube-controller-manager kube-scheduler kubectl kube-proxy";
    ;;
  node) 
    BINS="kubelet kubectl"
esac
case "$2" in 
  install)
    echo "${2} kubernetes ${1} (${K8S_VERSION})"
    for i in $BINS
    do
      wget -nv https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/$i --no-check-certificate -O ${BIN_PATH}/$i; 
    done
    ;;
  remove)
    echo "${2} kubernetes ${1} (${K8S_VERSION})"
    for i in $BINS
    do
      rm -v ${BIN_PATH}/$i; 
    done
    ;;
esac
