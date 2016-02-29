#!/usr/bin/env bash

# fail on any command exiting non-zero
set -eo pipefail

if [[ -z $DOCKER_BUILD ]]; then
  echo
  echo "Note: this script is intended for use by the Dockerfile and not as a way to build the controller locally"
  echo
  exit 1
fi

DEBIAN_FRONTEND=noninteractive
ETCD_VERSION=v2.2.2
CONFD_VERSION=0.10.0

# install common packages
apt-get update && apt-get install -y curl net-tools sudo uuid-runtime

# install etcdctl
curl -sSL https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz | \
  tar -xzf - -C /usr/local/bin --strip-components=1 "etcd-${ETCD_VERSION}-linux-amd64/etcdctl" && \
  chmod +x /usr/local/bin/etcdctl

# install confd
curl -sSL -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64 \
	&& chmod +x /usr/local/bin/confd

curl -sSL 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | apt-key add -
echo "deb http://ceph.com/debian-infernalis trusty main" > /etc/apt/sources.list.d/ceph.list

apt-get update && apt-get install -yq ceph lsb-release

apt-get clean -y

rm -Rf /usr/share/man /usr/share/doc
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
