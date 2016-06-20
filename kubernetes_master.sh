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
  if [ ! -x /usr/bin/flanneld ]; then 
    echo "flanneld build failed";
    exit;
  fi
fi
