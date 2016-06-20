#!/bin/bash
K8S_VERSION=$(curl -sS https://storage.googleapis.com/kubernetes-release/release/stable.txt)
BINS="kubernetes kube-apiserver kube-controller-manager kube-scheduler kubectl kubecfg kubelet kube-proxy";

for i in $BINS
do
  wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/$i --no-check-certificate -O /usr/local/bin/$i; 
done
