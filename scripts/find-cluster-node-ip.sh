docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker
