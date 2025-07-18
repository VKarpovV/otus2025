#!/bin/bash

# Установка Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Запуск сервисов
docker-compose down
docker-compose up -d

# Проверка
echo "Сервисы запущены:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000"
echo "- Kibana: http://localhost:5601"
