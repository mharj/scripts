#!/bin/bash
ETCD_VERSION=v2.3.7
FLANNELD_VERSION=v0.5.5
if [ -d /lib/systemd ]; then 
  if [ ! -x /usr/bin/etcdctl ] || [ ! -x /usr/bin/etcd ]; then
    curl -s https://raw.githubusercontent.com/mharj/scripts/master/common/etcd.sh | bash -s install ${ETCD_VERSION}
  fi
  if [ ! -x /usr/bin/etcdctl ] || [ ! -x /usr/bin/etcd ]; then 
    echo "etcd build failed";
    exit;
  fi
  if [ ! -x /usr/bin/flanneld ]; then
    curl -s https://raw.githubusercontent.com/mharj/scripts/master/common/flanneld.sh | bash -s install ${FLANNELD_VERSION}
  fi
  echo "flanneld systemd service"
  if [ ! -x /usr/local/bin/mk-docker-opts.sh ]; then
    wget -q https://raw.githubusercontent.com/coreos/flannel/master/dist/mk-docker-opts.sh -O /usr/local/bin/mk-docker-opts.sh
    chmod 755 /usr/local/bin/mk-docker-opts.sh
  fi
  wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/flanneld.service -O /lib/systemd/system/flanneld.service && \
  chmod 644 /lib/systemd/system/flanneld.service && \
  systemctl daemon-reload && \
  echo "done"
  echo "docker systemd setup (wait flanneld.service and options from flanneld startup)" && \
  mkdir -p /etc/systemd/system/docker.service.d && \
  wget -q https://raw.githubusercontent.com/mharj/scripts/master/flannel.conf -O /etc/systemd/system/docker.service.d/flannel.conf && \
  systemctl daemon-reload && \
  echo "done"
fi
