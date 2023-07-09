# Notes

## Remember docker

docker run -e SAY="..." taksan/k8s-bootcamp-cowsay:latest

## Creating and removing pods

```sh
kubectl run web --image=nginx
kubectl get pods
kubectl get pods -o yaml
```

## Declarative

Applying and removing manifests

```sh
kubectl apply -f <manifest file name>
kubectl delete -f  <manifest file name>
```

## Resources api

```sh
kubectl api-resources
kubectl api-versions
kubectl explain <object>
```

## Essential commands

```sh
$ kubectl [-n <namespace>] get <nome do recurso>
$ kubectl [-n <namespace>] get <nome do recurso> -o yaml
$ kubectl [-n <namespace>] get <nome do recurso> -o wide
$ kubectl [-n <namespace>] describe <nome do recurso>
$ kubectl [-n <namespace>] delete <nome do recurso>
```

## Exposing ports

```sh
kubectl port-forward pod/my-pod <local port>:<pod port>
```

## Looking at logs

```
kubectl logs <pod name>
kubectl logs <pod name> -f
```

## Executing commands inside de container in the pod

```sh
kubectl exec <pod> -- <command>

# running an interactive shell
kubectl exec -it <pod> -- sh
```
