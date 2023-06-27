JOB_NAME=$1
TASK_SCRIPT=$2
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB_NAME
spec:
  template:
    spec:
      containers:
      - name: task
        image: busybox
        args:
        - sh
        - -c
        - |
$(cat $TASK_SCRIPT | sed 's/^/          //')
      restartPolicy: Never
  backoffLimit: 0
EOF

# Aguarda o job terminar
kubectl wait --for=condition=complete --timeout=5m job/$JOB_NAME -n $NAMESPACE

# Obtem o log do job
kubectl logs job/$JOB_NAME -n $NAMESPACE