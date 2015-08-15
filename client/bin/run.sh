#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-08-08 19:06:18 +0100 (Sat, 08 Aug 2015)
#
#  vim:ts=2:sw=2:et
#

ETCD="${ETCD:-127.0.0.1:4001}"

if [[ "$1" == "sync" ]]; then
  cp /bin/rbd /opt/bin/${i} 
  chmod +x /opt/bin/${i}
fi

if [[ "$1" == "wait" ]]; then 
  confd -node $ETCD --confdir /app --log-level error --interval 5
fi

exec $@
