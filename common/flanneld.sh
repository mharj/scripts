#!/bin/bash
if [ "$#" -lt 1 ];then
  echo "Usage: $0 {install|remove} [version]"
  exit;
fi
case "$1" in 
  remove)
    rm -f /usr/bin/flanneld
    ;;
  install)
    if [ "$#" -lt 2 ];then
      echo "Usage: $0 install version"
      exit;
    fi  
    FLANNELD_VERSION=$2
    echo "Build flannel ${FLANNELD_VERSION}" && \
    if [ -d /opt/flannel ]; then rm -rf /opt/flannel;fi && \
    cd /opt && \
    git clone https://github.com/coreos/flannel.git && \
    cd /opt/flannel && \
    git checkout tags/${FLANNELD_VERSION} && \
    echo "FROM golang:1.6-onbuild" > Dockerfile && \
    mkdir /opt/flannel/bin && \
    if [[ "$(docker images -q coreos/flannel 2>/dev/null)" != "" ]]; then docker rmi coreos/flannel;fi && \
    docker build -t coreos/flannel . && \
    docker run -i -v /opt/flannel/bin:/go/src/app/bin --rm coreos/flannel /bin/bash -c "cd /go/src/app && ./build" && \
    install -o root -g root -m 0755 /opt/flannel/bin/flanneld /usr/bin/flanneld && \
    echo "cleanup" && \
    docker rmi coreos/flannel golang:1.6-onbuild && \
    echo "done"
    ;;
esac
