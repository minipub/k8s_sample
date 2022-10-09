#!/bin/bash

argv_host=$1
echo $argv_host

apt update

# common installation
apt install -y openssh-server apt-transport-https ca-certificates curl net-tools docker.io

# modify hostname
hostnamectl hostname $argv_host

# use cgroup to control docker 
cat <<EOF | tee /etc/docker/daemon.json
{
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
                "max-size": "100m"
        },
        "storage-driver": "overlay2"
}
EOF

systemctl enable docker
systemctl daemon-reload
systemctl restart docker

# add network proxy forward to sysctl 
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF

# validate
# sysctl -a | grep ip_forward

sysctl --system

# switch off the swap
swapoff -a

sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# validate
# free -m

# need to restart system
