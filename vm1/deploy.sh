#!/bin/bash

# Установка Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Подготовка директорий
mkdir -p www
echo "<h1>Hello from VM1 Apache</h1>" > www/index.html

# Запуск сервисов
docker-compose down
docker-compose up -d

# Проверка
echo "Проверка сервисов:"
curl -I http://localhost
curl -I http://localhost:8080
