### Trouble Shooting

1. No flannel env found on the worker node

scene: 

	- When command `kubectl apply the pod.yml` is executed, the Events message might be `Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "a7e86340893efd99107a81460249d6631b8cb5cb91d4f1a9828e5e9ba13ffb10" network for pod "mybox": networkPlugin cni failed to set up pod "mybox_default" network: open /run/flannel/subnet.env: no such file or directory`

problem: 

	- /run/flannel/subnet.env can't be found on the worker node

solution: 

	- copy /run/flannel/subnet.env of the master node to the worker node
