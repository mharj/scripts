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
