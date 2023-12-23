#!/bin/bash

set -eo pipefail

function now() {
    date +%Y-%m-%d" "%H-%M-%S
}

function info() {
  local CYAN='\033[1;36m'
  local RESET='\033[0m'
  echo -e "${CYAN}[INFO][$(now)] $*${RESET}"
  echo
}

# Based on https://kind.sigs.k8s.io/docs/user/quick-start/

info "Install and configures kind"

# Creates a cluster without the default networking addon because we will use calico
if ! kind get clusters | grep -q kind; then
  info "Installing kind..."
  kind create cluster --config=kind-config.yaml
else
  info "Kind cluster already exists"
fi

# Installs calico
info "Installing calico"
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml


# Installs metallb
# Reference: https://kind.sigs.k8s.io/docs/user/loadbalancer/
info "Installing MetalLB"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

# waits until metallb is ready
kubectl wait --namespace metallb-system \
             --for=condition=ready pod \
             --selector=app=metallb \
             --timeout=120s

# find the kind docker network subnet range
info "Getting docker network range..."
DOCKER_SUBNET=$(docker network inspect kind -f '{{range .IPAM.Config}}{{ if (eq 4 (len (split .Subnet "." ))) }}{{ (index (split .Subnet "/") 0 )}}{{end}}{{end}}')

# disables because we know there won't be spaces
# shellcheck disable=SC2001
START=$(echo "$DOCKER_SUBNET" | sed 's/\.0$/.200/')
# shellcheck disable=SC2001
END=$(echo "$DOCKER_SUBNET" | sed 's/\.0$/.250/')

info "Configuring MetalLB IPAddressPool and L2Advertisement. If the following throws an error about timeout, try to run this script again"
# create the resources to setup the load balancer
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - ${START}-${END}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF
