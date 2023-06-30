```sh
kubectl run --rm -it trial-and-error --image=bitnami/kubectl --command -- sh

$ kubectl cp sample-job.yaml alpine:/tmp
# cd /tmp
# kubectl apply -f sample-job.yaml
# kubectl get job
# kubectl logs job/sample-job
```
