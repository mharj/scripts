#!/bin/bash
if [ -d /lib/systemd ]; then 
  echo "Setup etcd" && \
  wget -q https://raw.githubusercontent.com/mharj/scripts/master/master/etcd.service -O /lib/systemd/system/etcd.service && \
  chmod 644 /lib/systemd/system/etcd.service && \
  systemctl daemon-reload && \
  echo "alias etcdctl='docker exec etcd /etcdctl'" > /etc/profile.d/etcd.sh && \
  source /etc/profile.d/etcd.sh && \
  if [ ! -f /etc/default/etcd ]; then echo -e "#ETCD_LISTEN_PEER_URLS default: \"http://localhost:2380,http://localhost:7001\"\nETCD_LISTEN_PEER_URLS=\n#ETCD_LISTEN_CLIENT_URLS default: \"http://localhost:2379,http://localhost:4001\"\nETCD_LISTEN_CLIENT_URLS=\n" > /etc/default/etcd;fi
  echo "done";
fi
