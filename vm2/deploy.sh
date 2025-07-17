#!/bin/bash

# Установка зависимостей
sudo apt-get update
sudo apt-get install -y git curl

# Установка Docker и Docker Compose
./common/setup_docker.sh

# Создание сетей Docker
docker network create frontend
docker network create backend

# Запуск сервисов через Docker Compose
docker-compose -f vm2/docker-compose.yml up -d

# Настройка репликации MySQL
./common/setup_replication.sh slave 192.168.140.133 192.168.140.132
