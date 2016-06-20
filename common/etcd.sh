#!/bin/bash
if [ "$#" -lt 1 ];then
  echo "Usage: $0 {install|remove} [version]"
  exit;
fi
case "$1" in
  setup_account)
    echo "setup etcd account"
    mkdir -p /var/lib/etcd
    if ! getent group etcd >/dev/null; then groupadd -fr etcd;fi
    if ! getent passwd etcd >/dev/null; then useradd -r -d /var/lib/etcd -g etcd etcd;fi
    chown -Rh etcd:etcd /var/lib/etcd    
    ;;
  remove)
    if [ -f /lib/systemd/system/etcd.service ]; then
      systemctl stop etcd
      systemctl disable etcd
      rm -f /lib/systemd/system/etcd.service
      systemctl daemon-reload
      systemctl reset-failed
    fi
    rm -f /usr/bin/etcd /usr/bin/etcdctl
    if getent passwd etcd >/dev/null; then userdel etcd;fi
    if getent group etcd >/dev/null; then groupdel etcd;fi
    ;;
  install)
    if [ "$#" -lt 2 ];then
      echo "Usage: $0 install version"
      exit;
    fi
    ETCD_VERSION=$2
    echo "Build etcd ${ETCD_VERSION}" && \
    if [ -d /opt/etcd ]; then rm -rf /opt/etcd;fi && \
    cd /opt && \
    git clone https://github.com/coreos/etcd && \
    cd /opt/etcd && \
    git checkout tags/${ETCD_VERSION} && \
    echo "FROM golang:1.6-onbuild" > Dockerfile && \
    rm -f .dockerignore && \
    docker build -t coreos/etcd . && \
    mkdir /opt/etcd/bin && \
    docker run -i -v /opt/etcd/bin:/go/src/app/bin --rm coreos/etcd /bin/bash -c "cd /go/src/app && ./build" && \
    install -o root -g root -m 0755 /opt/etcd/bin/etcd /usr/bin/etcd && \
    install -o root -g root -m 0755 /opt/etcd/bin/etcdctl /usr/bin/etcdctl && \
    docker rmi coreos/etcd && \
    cd /opt && \
    rm -rf /opt/etcd 
    setup_account
    if [ -d /lib/systemd ]; then
      wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/etcd.service -O /lib/systemd/system/etcd.service && \
      chmod 644 /lib/systemd/system/etcd.service && \
      systemctl daemon-reload
    fi
    echo "done"
    ;;
esac
