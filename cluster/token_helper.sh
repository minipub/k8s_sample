#!/bin/bash

### show current tokens
kubeadm token list

### create token with printing join command that will be used for worker node later
kubeadm token create --print-join-command
