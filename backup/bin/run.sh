#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-09-08 11:39:09 +0100 (Tue, 08 Sep 2015)
#
#  vim:ts=2:sw=2:et
#

SCHEDULE=${SCHEDULE:-""}
GO_CRON=${GO_CRON:-/go-cron}

# step: if we don't have a scheudule we use the ip address and default <IP>:00:00
if [ -z "${SCHEDULE}" ]; then
  HOUR=$(hostname -i | cut -d'.' -f3)
  ((HOUR=$HOUR+10))
  SCHEDULE="0 0 $HOUR * * *"
fi

echo "Scheduling the backup for: $SCHEDULE"

$GO_CRON "${SCHEDULE}" bin/bash -c "/usr/bin/ceph-backup -v"
