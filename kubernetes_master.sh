#!/bin/bash
echo "Setup etcd" && \
if [ -d /lib/systemd ]; then 
  echo "setup systemd";
fi && \
echo "done";
