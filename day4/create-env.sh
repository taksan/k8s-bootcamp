#!/bin/bash

set -e

cd $1
kubectl config set-context --current --namespace=$1
ls --color=none -1 *yml | xargs -I{} kubectl apply -f {}
