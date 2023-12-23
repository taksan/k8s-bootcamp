#!/bin/bash

set -eo pipefail

# Color codes
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print error messages in red
error() {
    echo -e "${RED}✘ Error: $*${NC}" >&2
}

# Function to print informational messages in cyan
info() {
    echo -e "${CYAN}$*${NC}"
}

# Function to print success messages in green
success() {
    echo -e "${GREEN}✔ $*${NC}"
}

# Function to remove pod and service
remove_pod_service() {
    info "Removing the pod and service..."

    kubectl delete pod hello-pod -n default --ignore-not-found=true
    kubectl delete service hello-service -n default --ignore-not-found=true
}

trap remove_pod_service EXIT

# Add checks for Kind cluster, MetalLB, nodes, and configurations as per the previous script.
# Check if Kind cluster is running
if ! kind get clusters | grep -q kind; then
    error "Kind cluster is not running. Verify that you run ./start-kind.sh and check for error messages"
    exit 1
else
    success "Kind cluster is running."
fi

# Check node readiness
info "Checking node readiness..."
nodes_status=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}')
if [[ $nodes_status == *"False"* ]]; then
    error "Some nodes are not ready. This might happen if calico failed to run. Check if pods below are crashing:"
    kubectl -n kube-system get pods | grep calico
    exit 1
else
    success "All nodes are ready."
fi

# Check Metallb pods health
info "Checking Metallb pods health..."
metallb_pods=$(kubectl get pods -n metallb-system --field-selector=status.phase=Running --no-headers=true | wc -l)
if [ "$metallb_pods" -eq 0 ]; then
    error "No Metallb pods are healthy. Check the following output: "
    kubectl get pods -n metallb-system
    exit 1
else
    success "Metallb pods are healthy."
fi

# Check Metallb configuration
info "Checking Metallb configuration..."
metallb_config=$(kubectl get IPAddressPool -n metallb-system example -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ -z "$metallb_config" ]; then
    error "Metallb configuration does not exist."
    exit 1
else
    success "Metallb configuration exists."
fi

# Check L2Advertisement
info "Checking L2Advertisement..."
l2_advertisement=$(kubectl get L2Advertisement -n metallb-system empty -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ -z "$l2_advertisement" ]; then
    error "L2Advertisement does not exist."
    exit 1
else
    success "L2Advertisement exists."
fi

info "All basic checks passed, do a quick integration test."

# Create a simple nginx pod with a label
info "Creating a simple nginx pod..."
kubectl run hello-pod --image=nginx --restart=Never -n default --labels=run=hello-pod

# Wait for the pod to become ready
info "Waiting for the pod to become ready..."
kubectl wait --for=condition=Ready pod -l run=hello-pod -n default --timeout=60s

# Expose the pod as a service using MetalLB
info "Exposing the pod as a service..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  type: LoadBalancer
  selector:
    run: hello-pod
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

# Wait for MetalLB to assign an external IP to the service
info "Waiting for MetalLB to assign an external IP to the service..."
external_ip=""
timeout_start=$(date +%s)
while [ -z "$external_ip" ]; do
    external_ip=$(kubectl get svc hello-service -n default -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
    sleep 5

    timeout_end=$(date +%s)
    duration=$((timeout_end - timeout_start))
    if [ "$duration" -ge 300 ]; then
        error "Timeout exceeded waiting for MetalLB to assign an external IP to the service."
        exit 1
    fi
done

success "External IP assigned to the service: $external_ip"

# Perform a curl request to the pod using the assigned external IP
info "Performing a curl request to the pod..."
curl_response=$(curl -s -o /dev/null -w "%{http_code}" "$external_ip")
if [ "$curl_response" -eq 200 ]; then
    success "Curl response code: $curl_response"
    success "Integration test passed."
else
    error "Integration test failed. Unexpected response code: $curl_response"
    exit 1
fi

success "Integration test completed successfully."
