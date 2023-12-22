helm upgrade --install kubegrafana prometheus-community/kube-prometheus-stack -n kubegrafana --create-namespace -f kube-grafana-values.yml

echo "Credenciais padrão"

echo "Usuário"
kubectl -n kubegrafana get secret kubegrafana -o jsonpath='{.data.admin\-user}' | base64 -d

echo "Senha"
kubectl -n kubegrafana get secret kubegrafana -o jsonpath='{.data.admin\-password}' | base64 -d

echo "Aguarda criação das entradas no /etc/hosts"
sleep 10

./create-ingress-host-entry.sh kubegrafana kubegrafana
