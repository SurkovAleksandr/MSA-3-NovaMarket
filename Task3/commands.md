Для запуска Locust надо выполнить команду `locust` в директории, в которой есть [locustfile.py](locustfile.py).

Сборка образа scaletestapp и загрузка в minikube
```shell
docker build -t scaler-app:1.1.3 ./scaletestapp
minikube image load scaler-app:1.1.3
```

Деплой приложения в Kubernetes
```shell
helm upgrade --install scaler-app ./scaler-app --debug
```

```shell
helm uninstall scaler-app ./scaler-app --debug
```

Обновление prometheus-operator с доплнительным файлом prometheus-operator-values.yml(обычно называют value.yaml)
```shell
helm upgrade --install prometheus-operator prometheus-community/kube-prometheus-stack -f ./result/prometheus-operator-values.yml 
```

Обновление prometheus-adapter
```shell
helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter -f ./result/prometheus-adapter-value.yaml 
```

## Проверка prometheus
1. Свойство resources не должно быть пустым
```shell
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .
```
2. Не должно быть ошибок
```shell
kubectl describe hpa scaler-app
```
