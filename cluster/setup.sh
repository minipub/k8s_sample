#!/bin/bash

node_type=$1

## short alias for generating yaml config
## easy to used with kubectl run & create
echo 'export OUT="--dry-run=client -o=yaml"' >> ~/.bashrc

# add k8s aliyun apt image source
curl "https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg" | sudo apt-key add -

cat <<EOF | tee /etc/apt/sources.list.d/k8s.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

apt update

apt install -y kubeadm=1.23.3-00 kubelet=1.23.3-00 kubectl=1.23.3-00

apt-mark hold kubeadm kubelet kubectl

mkdir ~/apps && cd ~/apps

# replace docker image source
cat <<EOF | tee pull.sh
#!/bin/bash

repo=registry.aliyuncs.com/google_containers

for name in `kubeadm config images list --kubernetes-version v1.23.3`; do
        src_name=${name#k8s.gcr.io/}
        src_name=${src_name#coredns/}
        docker pull $repo/$src_name
        docker tag $repo/$src_name $name
        docker rmi $repo/$src_name
done
EOF

chmod +x pull.sh

if [ $node_type == "master" ]; then
	echo "master node branch."

	# quick start k8s master node
	# using the last line of the installation.out `kubeadm join` to make worker node easy to join cluster
	kubeadm init --pod-network-cidr=10.0.0.0/16 --apiserver-advertise-address=192.168.56.101 --kubernetes-version=v1.23.3 > installation.out 2>&1

	mkdir -p $HOME/.kube
	cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config

	# STATUS NotReady for no network tool manager
	# kubectl get node

	wget "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"

	## modify: kube-flannel.yml: 
	##		object: net-conf.json
	##		key: Network 
	##		value: same as --pod-network-cidr 

	kubectl apply -f kube-flannel.yml

	# Now STATUS is Ready
	# kubectl get node
else
	echo "worker node branch."

	# copy $HOME/.kube/config of master node to worker node
	# or, master node could not be discovered on worker node
	mkdir -p $HOME/.kube
	scp k8s-master:$HOME/.kube/config $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config

	cat <<RLEOF | tee /etc/rc.local
#!/bin/bash

cat <<EOF | tee /run/flannel/subnet.env
FLANNEL_NETWORK=10.0.0.0/16
FLANNEL_SUBNET=10.0.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF
RLEOF

	chmod +x /etc/rc.local

	cat <<EOF | tee /lib/systemd/system/rc-local.service
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOF

fi
