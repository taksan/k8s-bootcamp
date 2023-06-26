import requests

# troque o IP abaixo pelo IP do event viewer
target="http://192.168.162.138:5000/api/events"
message = {"environment": "foo", "content": "bar"}
requests.post(url=target, json=message)
