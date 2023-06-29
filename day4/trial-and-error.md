```sh
$ kubectl run -i --tty alpine --image=bitnami/kubectl --  bash

$ kubectl cp sample-job.yaml alpine:/tmp
# cd /tmp
# kubectl apply -f sample-job.yaml
# kubectl get job
# kubectl logs job/sample-job
