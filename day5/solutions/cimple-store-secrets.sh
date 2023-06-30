kubectl create secret generic cimple-store-secret \
	--from-literal=db-user=storeuser \
	--from-literal=db-pass=storepass