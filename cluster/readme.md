## Install

### Prepare

1. login to the aim server
2. $ wget -O /tmp/prepare.sh "https://raw.githubusercontent.com/minipub/k8s_sample/main/cluster/prepare.sh"
3. $ chmod +x /tmp/prepare.sh
4. $ sudo /tmp/prepare.sh $host_name

### Setup

1. login to the aim server
2. $ wget -O /tmp/setup.sh "https://raw.githubusercontent.com/minipub/k8s_sample/main/cluster/setup.sh"
3. $ chmod +x /tmp/setup.sh
4. $ sudo /tmp/setup.sh $node_type
