#!/bin/bash

if [[ ! -e cronjob-template.yml ]]; then
	echo "Missing cronjob-template.yml"
	exit 1
fi
if [[ ! -e job-template.yml ]]; then
	echo "Missing job-template.yml"
	exit 1
fi


kubectl create configmap cimple-back-templates --from-file=cronjob-template.yml --from-file=job-template.yml --dry-run=client -o yaml | kubectl apply -f -
