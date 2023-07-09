helm upgrade --install kubegrafana prometheus-community/kube-prometheus-stack -n kubegrafana --create-namespace -f kube-grafana-values.yml
