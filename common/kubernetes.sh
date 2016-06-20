#!/bin/bash
BIN_PATH=/usr/bin
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
    if ! getent group kube >/dev/null; then groupadd -fr kube;fi && \
    if ! getent passwd kube >/dev/null; then useradd -r -d /var/lib/kube -g kube kube;fi
    mkdir -p /var/run/kubernetes 
    chown -Rh kube:kube /var/run/kubernetes
    for i in $BINS
    do
      wget -nv https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/$i --no-check-certificate -O ${BIN_PATH}/$i;
      chmod 755 ${BIN_PATH}/$i
      case $i in 
        kube-apiserver)
          [ -x /bin/systemctl ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/services/systemd/${i}.service -O /lib/systemd/system/${i}.service
          [ ! -f /etc/kubernetes/master/apiserver.conf ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/etc/kubernetes/master/apiserver.conf -O /etc/kubernetes/master/apiserver.conf
          ;;
        kube-controller-manager)
          [ -x /bin/systemctl ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/services/systemd/${i}.service -O /lib/systemd/system/${i}.service
          [ ! -f /etc/kubernetes/master/controller-manager.conf ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/etc/kubernetes/master/controller-manager.conf -O /etc/kubernetes/master/controller-manager.conf
          ;;
        kube-scheduler)
          [ -x /bin/systemctl ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/services/systemd/${i}.service -O /lib/systemd/system/${i}.service
          [ ! -f /etc/kubernetes/master/scheduler.conf ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/master/etc/kubernetes/master/scheduler.conf -O /etc/kubernetes/master/scheduler.conf
          ;;
        kube-proxy)
          [ -x /bin/systemctl ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/node/services/systemd/${i}.service -O /lib/systemd/system/${i}.service
          [ ! -f /etc/kubernetes/node/kube-proxy.conf ] && wget -nv https://raw.githubusercontent.com/kismatic/kubernetes-distro-packages/master/kubernetes/node/etc/kubernetes/node/kube-proxy.conf -O /etc/kubernetes/node/kube-proxy.conf
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
      case $i in 
        kube-apiserver)
          [ -x /bin/systemctl ] && [ -f /lib/systemd/system/${i}.service ] && rm -f /lib/systemd/system/${i}.service && service ${i} stop
          ;;
        kube-controller-manager)
          [ -x /bin/systemctl ] && [ -f /lib/systemd/system/${i}.service ] && rm -f /lib/systemd/system/${i}.service && service ${i} stop
          ;;
        kube-scheduler)
          [ -x /bin/systemctl ] && [ -f /lib/systemd/system/${i}.service ] && rm -f /lib/systemd/system/${i}.service && service ${i} stop
          ;;
        kube-proxy)
          [ -x /bin/systemctl ] && [ -f /lib/systemd/system/${i}.service ] && rm -f /lib/systemd/system/${i}.service && service ${i} stop
          ;;          
      esac
    done
    ;;
esac
