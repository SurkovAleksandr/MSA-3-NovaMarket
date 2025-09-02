Для работы через ingress связываем DNS и IP
```shell
for i in {1..100000}; do
  curl --resolve "scaler.app:8080:192.168.49.2" -H "User-Agent: Mobile" -i http://scaler.app/api/asd
done 
```

### Использование nginx как прокси
```shell
VERSION=1.22

docker build -t nginx-rate-limit:$VERSION ./nginx
minikube image load nginx-rate-limit:$VERSION
kubectl delete deployment nginx-rate-limit
kubectl create deployment nginx-rate-limit --image=nginx-rate-limit:$VERSION
```

```shell
kubectl expose deployment nginx-rate-limit --type=NodePort --port=8080 --target-port=80
```

Тестирование Rate Limit
```shell
for i in {1..1000}; do
  sleep 1
  curl -s -o /dev/null -w "%{http_code} " localhost:8080/api/mobile/v1
done 
```


Тестирование Circuit breaker
```shell
# Проверяем что сервис доступен
for i in {1..5}; do
  curl -s -o /dev/null -w "%{http_code} " localhost:8080/api/mobile/v1
done 

# Останавливаем внешний сервис
kubectl delete deployment scaler-app

# Делаем запросы, чтобы получили 5 ошибок.
for i in {1..6}; do
  sleep 1
  
  curl -s -o /dev/null -w "%{http_code} " localhost:8080/api/mobile/v1  
done 

# Поднимаем внешний сервис
helm upgrade --install scaler-app ../Task3/scaler-app

# Проверяем что сервис доступен
for i in {1..5}; do
  sleep 5
  
  curl -s -o /dev/null -w "%{http_code} " localhost:8080/api/mobile/v1
done 
```
