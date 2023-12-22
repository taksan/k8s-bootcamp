#!/usr/bin/env bash

set -eo pipefail

# shellcheck disable=SC2016
sed 's/$ENVIRONMENT/dev/g' all.yml | kubectl apply -f -

# shellcheck disable=SC2016
sed 's/$ENVIRONMENT/prod/g' all.yml | kubectl apply -f -

kubectl apply -f cimple-eviewer-all.yml

./install-ingress-controller.sh
