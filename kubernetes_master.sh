#!/bin/bash
echo "Setup etcd" && \
if [ -d /lib/systemd ]; then 
  wget https://raw.githubusercontent.com/mharj/scripts/master/master/etcd.service -O /lib/systemd/system/etcd.service
  chmod 644 /lib/systemd/system/etcd.service
  systemctl daemon-reload
fi && \
echo "done";
