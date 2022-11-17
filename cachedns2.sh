



API_HOST=$(</dev/urandom tr -dc a-z0-9|head -c32).edns.ip-api.com; API_IP=$(dig $API_HOST +short @80.58.0.33); curl -H "Host: $API_HOST" http://$API_IP/json
