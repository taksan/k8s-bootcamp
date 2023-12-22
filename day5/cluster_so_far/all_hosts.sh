#!/usr/bin/env bash

set -eo pipefail

# shellcheck disable=SC2046
cd $(dirname $(realpath "$0"))

function add_to_hosts() {
  ../../scripts/create-ingress-host-entry.sh "$@"
}

kubectl get ingress --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.namespace}{"\n"}{end}' |\
while read -r INGRESS NAMESPACE; do
  add_to_hosts "$INGRESS" "$NAMESPACE"
done