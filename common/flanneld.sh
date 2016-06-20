#!/bin/bash
if [ "$#" -lt 1 ];then
  echo "Usage: $0 {install|remove} [version]"
  exit;
fi
case "$1" in 
  remove)
    if [ -f /lib/systemd/system/flanneld.service ]; then # stop, remove file and reload systemd
      systemctl stop flanneld
      systemctl disable flanneld
      rm -f /lib/systemd/system/flanneld.service
      systemctl daemon-reload
      systemctl reset-failed
    fi
    if [ -f /etc/init.d/flanneld ]; then # stop, clean init and file
      service flanneld stop
      update-rc.d flanneld remove
      rm -f /etc/init.d/flanneld
    fi
    rm -f /usr/bin/flanneld /usr/local/bin/mk-docker-opts.sh
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
    elif [ -x /usr/sbin/update-rc.d ]; then # install etcd debian initd
      wget -q https://raw.githubusercontent.com/mharj/scripts/master/common/flanneld.init -O /etc/init.d/flanneld
      chmod 755 /etc/init.d/flanneld
      update-rc.d flanneld defaults
    fi
    if [ ! -x /usr/local/bin/mk-docker-opts.sh ]; then
      wget -q https://raw.githubusercontent.com/coreos/flannel/master/dist/mk-docker-opts.sh -O /usr/local/bin/mk-docker-opts.sh
      chmod 755 /usr/local/bin/mk-docker-opts.sh
    fi
    echo "done"
    ;;
esac
