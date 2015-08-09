#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-08-08 19:06:18 +0100 (Sat, 08 Aug 2015)
#
#  vim:ts=2:sw=2:et
#
if [[ "$1" == "sync" ]]; then
  cp /bin/rbd /opt/bin/${i} 
  chmod +x /opt/bin/${i}
fi

exec $@
