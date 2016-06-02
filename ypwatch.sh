#!/bin/bash
[ -f yp_seen ] || touch yp_seen
mapfile -t yp_seen < yp_seen # load old seen file as array
TCP=$(netstat -lpn | awk -F' +|:' '/tcp.*ypserv/ {print $5}');
UDP=$(netstat -lpn | awk -F' +|:' '/udp.*ypserv/ {print $5}');
function in_array () {
        local e
        for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
        return 1
}
function handleList() {
        while read data; do
                IP=$(echo $data | awk '{print $3}' |awk -F. '{print $1"."$2"."$3"."$4}');
                in_array "$IP" "${yp_seen[@]}"
                if [ "$?" == "1" ]; then # not seen yet
                        yp_seen+=("$IP"); # add to array
                        echo $IP >> yp_seen; # save to file
                fi
        done
}
tcpdump -nn udp dst port $UDP or tcp dst port $TCP 2>/dev/null| handleList
