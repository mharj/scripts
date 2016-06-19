#!/bin/bash
if [ -d /lib/systemd ]; then 
  echo "Setup etcd" && \
  wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/etcd.service -O /lib/systemd/system/etcd.service && \
  chmod 644 /lib/systemd/system/etcd.service && \
  systemctl daemon-reload && \
  echo "alias etcdctl='docker exec etcd /etcdctl'" > /etc/profile.d/etcd.sh && \
  source /etc/profile.d/etcd.sh && \
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
  alias etcdctl='docker exec etcd /etcdctl' && \
  alias && \
  wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/flanneld.service -O /lib/systemd/system/flanneld.service && \
  chmod 644 /lib/systemd/system/flanneld.service && \
  systemctl daemon-reload && \
  etcdctl get /coreos.com/network/config >/dev/null && \
  if [ "$?" == "0" ]; then echo "network defined, starting flanned";service flanneld restart;fi && \
  echo "done"
fi
