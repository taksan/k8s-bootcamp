# Notes

## Finding the IP address of a pod

```sh
$ kubectl get pods -o wide

NAME                       READY   STATUS              RESTARTS   AGE IP                NODE          NOMINATED NODE   READINESS GATES
cimple-back                1/1     Running             0          8s  192.168.162.137   kind-worker   <none>           <none>
cimple-eviewer             1/1     ContainerCreating   0          8s  192.168.162.138   kind-worker   <none>           <none>
...

```
