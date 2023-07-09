# needs the eviwer pod ip address
curl -X POST http://${EVIEWER_POD_IP}/api/events --data '{"environment": "foo", "content": "bar"}'
