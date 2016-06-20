#!/bin/bash
if [ "$#" -lt 1 ];then
  echo "Usage: $0 {install|remove} [version]"
  exit;
fi
case "$1" in 
  remove)
    if [ -f /lib/systemd/system/flanneld.service ]; then
      systemctl stop flanneld
      systemctl disable flanneld
      rm -f /lib/systemd/system/flanneld.service
      systemctl daemon-reload
      systemctl reset-failed
    fi  
    rm -f /usr/bin/flanneld
    ;;
  install)
    if [ "$#" -lt 2 ];then
      echo "Usage: $0 install version"
      exit;
    fi  
    FLANNELD_VERSION=$2
    echo "Build flannel ${FLANNELD_VERSION} (ignored)" && \
    if [ -d /opt/flannel ]; then rm -rf /opt/flannel;fi && \
    cd /opt && \
    git clone https://github.com/coreos/flannel.git && \
    cd /opt/flannel && \
#    git checkout tags/${FLANNELD_VERSION} && \
    echo "FROM golang:1.6-onbuild" > Dockerfile && \
    mkdir /opt/flannel/bin && \
    if [[ "$(docker images -q coreos/flannel 2>/dev/null)" != "" ]]; then docker rmi coreos/flannel;fi && \
    docker build -t coreos/flannel . && \
    docker run -i -v /opt/flannel/bin:/go/src/app/bin --rm coreos/flannel /bin/bash -c "cd /go/src/app && ./build" && \
    install -o root -g root -m 0755 /opt/flannel/bin/flanneld /usr/bin/flanneld && \
    echo "cleanup" && \
    docker rmi coreos/flannel golang:1.6-onbuild && \
    if [ -x /bin/systemctl ]; then # install etcd systemd service and set start etcd => flanneld => docker
      wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/flanneld.service -O /lib/systemd/system/flanneld.service && \
      chmod 644 /lib/systemd/system/flanneld.service && \
      mkdir -vp /etc/systemd/system/docker.service.d && \
      wget -q https://raw.githubusercontent.com/mharj/scripts/master/flannel.conf -O /etc/systemd/system/docker.service.d/flannel.conf && \
      systemctl daemon-reload
    fi
    echo "done"
    ;;
esac
