#!/usr/bin/env bash

set -eo pipefail

function add_to_hosts() {
  ../../scripts/create-ingress-host-entry.sh "$@"
}

add_to_hosts cimple-front dev
add_to_hosts cimple-back dev
add_to_hosts cimple-front prod
add_to_hosts cimple-back prod
add_to_hosts cimple-eviewer audit