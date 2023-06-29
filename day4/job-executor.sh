#!/bin/sh

TASK_ID=$1
BUILD_ID=$2
TASK_IMAGE=$(curl -s http://localhost:8000/tasks/"$TASK_ID"/field/image)
if  [ -z "$TASK_IMAGE" ]; then
  echo "Image not specified, using 'alpine' as default image"
  TASK_IMAGE=alpine
else
  echo "Image specified: $TASK_IMAGE. Warning, only alpine based images are supported"
fi

echo "Will run task $TASK_ID with image $TASK_IMAGE and build $BUILD_ID"
JOB_NAME=job-$RANDOM-${TASK_ID}-${BUILD_ID}

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB_NAME
spec:
  ttlSecondsAfterFinished: 10
  template:
    spec:
      containers:
        - name: task
          image: $TASK_IMAGE
          args:
            - sh
            - -c
            - |
              set -e -x

              # makes sure curl is installed
              apk add --no-cache curl

              # the remaining of the script is the same as executor.sh
              curl -f -s http://cimple-back/tasks/$TASK_ID/field/script > task-script.sh
              chmod u+x task-script.sh
              ./task-script.sh >output.log 2>&1

              curl -f -s -X POST -F 'file=@output.log' http://cimple-back/tasks/$TASK_ID/builds/$BUILD_ID?exit_code=$?
      restartPolicy: Never
  backoffLimit: 0
EOF
