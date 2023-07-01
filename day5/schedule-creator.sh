#!/usr/bin/env bash

TASK_ID="$1"
JOB_SCHEDULE="$2"
CRONJOB_NAME="$3"

if [[ -z $BACKEND_SERVICE ]]; then
  BACKEND_SERVICE="http://cimple-back"
fi

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: $CRONJOB_NAME
spec:
  schedule: "$JOB_SCHEDULE"
  jobTemplate:
    spec:
      ttlSecondsAfterFinished: 10
      template:
        spec:
          containers:
          - name: task
            image: curlimages/curl:8.00.1
            command: [ "/bin/sh", "-c" ]
            args:
              - |
                # triggers the task
                curl -X POST -H "X-CLIENT-ID: schedule manager" "$BACKEND_SERVICE"/tasks/$TASK_ID/trigger
          restartPolicy: Never
      backoffLimit: 0
EOF
