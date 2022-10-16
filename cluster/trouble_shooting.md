# Trouble Shooting

### Flannel

1. No flannel env found on the worker node

Scene: 

	- When command `kubectl apply the pod.yml` is executed, the Events message might be `Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "a7e86340893efd99107a81460249d6631b8cb5cb91d4f1a9828e5e9ba13ffb10" network for pod "mybox": networkPlugin cni failed to set up pod "mybox_default" network: open /run/flannel/subnet.env: no such file or directory`

Problem: 

	- /run/flannel/subnet.env can't be found on the worker node. 

Solution: 

	- copy /run/flannel/subnet.env of the master node to the worker node.

2. Flannel failed to create subnetmanager because retrieving pod spec error

Scene:

	- Failed to create subnetmanager: error retrieving pod spec for kube-flannel get "https://10.96.0.1:443/api/v1/namespaces/kube-flannel/pods/kube-flannel-ds-72nkb": dial tcp 10.96.0.1:443: i/o timeout

Problem: 

	- It may cause that the file /run/flannel/subnet.env can't be found on the worker node.

Root Cause: 

	- The easiest way to solve the last problem is to copy /run/flannel/subnet.env of the master node to the worker node, but actually that's not right, because the file /run/flannel/subnet.env is created by the POD kube-flannel-pod which is controlled by DAEMONSET kube-flannel-ds. When the flannel was deployed on the worker node, it tried to access flannel config through apiserver with the k8s service default ClusterIP.
	- When you execute curl on master node, it returns the real execution result, but if it does on the worker node, you will find that the ClusterIP address even can't be resolved. That means the pod kube-flannel-pod may be something wrong at the deployment, and will cause that subnet.env can't be created later.

Solution: 

	- https://github.com/flannel-io/flannel/issues/671#issuecomment-1093155995
	- Add the right interface to command args, or add two variables of apiserver: KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT(See above for more details) to the env of container part of kube-flannel.yml. 
