#!/bin/bash
if [ "$#" -lt 1 ];then
  echo "Usage: $0 {install|remove} [version]"
  exit;
fi
function setup_account {
    echo "*** setup etcd account"
    mkdir -vp /var/lib/etcd && \
    if ! getent group etcd >/dev/null; then groupadd -fr etcd;fi && \
    if ! getent passwd etcd >/dev/null; then useradd -r -d /var/lib/etcd -g etcd etcd;fi && \
    chown -Rh etcd:etcd /var/lib/etcd
}
case "$1" in
  setup_account)
    setup_account
    ;;
  remove)
    echo "*** remove etcd service"
    if [ -f /lib/systemd/system/etcd.service ]; then # stop, clean systemd and file
      systemctl stop etcd
      systemctl disable etcd
      rm -f /lib/systemd/system/etcd.service
      systemctl daemon-reload
      systemctl reset-failed
    fi
    if [ -f /etc/init.d/etcd ]; then # stop, clean init and file
      service etcd stop
      update-rc.d etcd remove
      rm -f /etc/init.d/etcd
    fi    
    rm -f /usr/bin/etcd /usr/bin/etcdctl
    echo "*** remove etcd account"
    if getent passwd etcd >/dev/null; then userdel etcd;fi
    if getent group etcd >/dev/null; then groupdel etcd;fi
    ;;
  install)
    if [ "$#" -lt 2 ];then
      echo "Usage: $0 install version"
      exit;
    fi
    ETCD_VERSION=$2
    # build etcd with docker image and container
    echo "*** build etcd ${ETCD_VERSION}" && \
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
    if [ -x /bin/systemctl ]; then # install etcd systemd service
      wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/etcd.service -O /lib/systemd/system/etcd.service && \
      chmod 644 /lib/systemd/system/etcd.service && \
      systemctl daemon-reload
    elif [ -x /usr/sbin/update-rc.d ]; then # install etcd debian initd
      wget -q https://raw.githubusercontent.com/mharj/scripts/master/common/etcd.init -O /etc/init.d/etcd
      chmod 755 /etc/init.d/etcd
      update-rc.d etcd defaults
    fi
    # base ENV settings file for etcd
    if [ -d /etc/default ] && [ ! -f /etc/default/etcd ]; then 
      cat << EOF > /etc/default/etcd
#ETCD_LISTEN_PEER_URLS default: \"http://localhost:2380,http://localhost:7001\"
ETCD_LISTEN_PEER_URLS=
#ETCD_LISTEN_CLIENT_URLS default: \"http://localhost:2379,http://localhost:4001\"
ETCD_LISTEN_CLIENT_URLS=
#ETCD_ADVERTISE_CLIENT_URLS default: "http://localhost:2379,http://localhost:4001"
ETCD_ADVERTISE_CLIENT_URLS=
EOF
    fi    
    echo "*** done"
    ;;
esac
