#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-08-08 19:06:18 +0100 (Sat, 08 Aug 2015)
#
#  vim:ts=2:sw=2:et
#
# step: somewhat hacky where to pass down the version and registry
sed -i "s/%REGISTRY%/${REGISTRY}/" /bin/rbd
sed -i "s/%TAG%/${TAG}/" /bin/rbd

cp /bin/rbd /opt/bin/${i} && chmod +x /opt/bin/${i}

# loop forever until the container is stopped
if [[ $1 == "sync" ]]; then
  while true; do
    sleep 1
  done
fi

exec $@
