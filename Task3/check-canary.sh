#!/bin/bash

set -e

echo "▶️ Checking canary release (90% v1, 10% v2)..."

# Посылаем 100 запросов
# Сервис разворачивал в minikube. Изначально в kind: Service у свойства spec.type было значение ClusterIP.
# Пытался вызвать http://localhost:9090/ping через port-forward. Но запросы шли на тот deploy сервиса, который устанавливался первым(чтобы понять это перезапускал деплой одной версии сервиса).
# После этого заменил type: NodePort и получил IP при помощи команды
# minikube service scaler-app --url
# трафик начал распределяться примерно одинаково несмотря на настройки весов при этом запросы через port-forward по-прежнему шли на одну версию сервиса.


 #URL=$(minikube service booking-ui --url) # для canary deployment
 URL=$(minikube service scaler-app --url)
 echo $URL

declare -i count_v1=0
declare -i count_v2=0

for i in {1..100000}; do
    response=$(curl -s -H 'X-Feature-Enabled: true' "$URL/ping")
    # Тут важно получить порт ingres(если он настроен), чтобы запросы шли через его sidecar. Если получить порт сервиса через minikube service,
    # то запросы будут делиться в пропорции 50%
    # kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'
    #response=$(curl -s -H 'X-Feature-Enabled: false' -H "Host: scaler-app.default.svc.cluster.local" "http://192.168.49.2:30165/ping")

    echo -n $response

    if [[ "$response" =~ "1." ]] ; then
        count_v1+=1
    else
        count_v2+=1
    fi
done

echo
echo "Count V1: $count_v1"
echo "Count V2: $count_v2"