#!/bin/bash
K8S_VERSION=$(curl -sS https://storage.googleapis.com/kubernetes-release/release/stable.txt)
case "$1" in 
  master)
    BINS="kube-apiserver kube-controller-manager kube-scheduler kubectl kube-proxy";
    ;;
  node) 
    BINS="kubelet kubectl"
esac
for i in $BINS
do
  wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/$i --no-check-certificate -O /usr/local/bin/$i; 
done
