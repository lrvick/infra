#!/bin/bash


kubeconfig_out="$(mktemp -p /dev/shm/)"
chmod 600 "$kubeconfig_out"
terraform output kubeconfig > "$kubeconfig_out"

export KUBECONFIG="$kubeconfig_out"
