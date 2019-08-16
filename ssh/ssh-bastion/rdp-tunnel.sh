#!/bin/sh

scriptname="$(basename $0)"

if [ $# -lt 5 ]
 then
    echo "Usage: $scriptname start | stop LOCAL_PORT  RDP_NODE_PORT  RDP_NODE_IP  SSH_BASTION_NODE_IP"
    exit
fi

case "$1" in

start)

  echo "Starting tunnel to $5"
  ssh -M -S ~/.ssh/$scriptname.control -fnNT -L $2:$4:$3  $5
  ssh -S ~/.ssh/$scriptname.control -O check $5
  ;;

stop)
  echo "Stopping tunnel to $5"
  ssh -S ~/.ssh/$scriptname.control -O exit $5

 ;;

*)
  echo "Did not understand your argument, please use start|stop"
  ;;

esac
