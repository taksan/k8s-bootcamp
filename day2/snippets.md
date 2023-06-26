
## port forward

```sh
kubectl port-forward pod/cimple-front 8080:80
```

## criando o back
```sh
kubectl apply -f cimple-back.yaml
```


## vendo logs

```sh
kubectl logs <pod>     # apresenta os logs e sai
kubectl logs <pod> -f  # faz “tail” dos logs
```

## recriando o back

```sh
kubectl delete -f cimple-back.yaml
kubectl apply -f cimple-back.yaml
```

## executando comandos dentro do pod

```sh
kubectl exec -it <pod name> -- sh
```


