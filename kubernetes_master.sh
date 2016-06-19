#!/bin/bash
if [ -d /lib/systemd ]; then 
  if [ ! -x /usr/bin/etcdctl ] || [ ! -x /usr/bin/etcd ]; then 
    echo "Build etcd" && \
    if [ -d /opt/etcd ]; then rm -rf /opt/etcd;fi && \
    cd /opt && \
    git clone https://github.com/coreos/etcd && \
    cd /opt/etcd && \
    echo "FROM golang:1.6-onbuild" > Dockerfile && \
    rm -f .dockerignore && \
    docker build -t coreos/etcd . && \
    mkdir /opt/etcd/bin && \
    docker run -i -v /opt/etcd/bin:/go/src/app/bin --rm coreos/etcd /bin/bash -c "cd /go/src/app && ./build" && \
    install -o root -g root -m 0755 /opt/etcd/bin/etcd /usr/bin/etcd && \
    install -o root -g root -m 0755 /opt/etcd/bin/etcdctl /usr/bin/etcdctl && \
    echo "done"
  fi
  if [ ! -x /usr/bin/etcdctl ] || [ ! -x /usr/bin/etcd ]; then 
    echo "etcd build failed";
    exit;
  fi
  echo "Setup etcd service" && \
  wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/etcd.service -O /lib/systemd/system/etcd.service && \
  chmod 644 /lib/systemd/system/etcd.service && \
  systemctl daemon-reload && \
  if [ ! -f /etc/default/etcd ]; then 
    cat << EOF > /etc/default/etcd
#ETCD_LISTEN_PEER_URLS default: \"http://localhost:2380,http://localhost:7001\"
ETCD_LISTEN_PEER_URLS=
#ETCD_LISTEN_CLIENT_URLS default: \"http://localhost:2379,http://localhost:4001\"
ETCD_LISTEN_CLIENT_URLS=
#ETCD_ADVERTISE_CLIENT_URLS default: "http://localhost:2379,http://localhost:4001"
ETCD_ADVERTISE_CLIENT_URLS=
EOF
  fi
  echo "done";
  if [ ! -x /usr/bin/flanneld ]; then 
    echo "Build flannel" && \
    if [ -d /opt/flannel ]; then rm -rf /opt/flannel;fi && \
    cd /opt && \
    git clone https://github.com/coreos/flannel.git && \
    cd /opt/flannel && \
    echo "FROM golang:1.6-onbuild" > Dockerfile && \
    mkdir /opt/flannel/bin && \
    if [[ "$(docker images -q coreos/flannel 2>/dev/null)" != "" ]]; then docker rmi coreos/flannel;fi && \
    docker build -t coreos/flannel . && \
    docker run -i -v /opt/flannel/bin:/go/src/app/bin --rm coreos/flannel /bin/bash -c "cd /go/src/app && ./build" && \
    install -o root -g root -m 0755 /opt/flannel/bin/flanneld /usr/bin/flanneld && \
    echo "cleanup" && \
    docker rmi coreos/flannel golang:1.6-onbuild && \
    echo "done"
  fi
  echo "flanneld systemd service" && \
  wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/flanneld.service -O /lib/systemd/system/flanneld.service && \
  chmod 644 /lib/systemd/system/flanneld.service && \
  systemctl daemon-reload && \
  echo "done"
fi
