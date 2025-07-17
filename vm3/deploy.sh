#!/bin/bash

# Установка зависимостей
sudo apt-get update
sudo apt-get install -y git curl

# Установка Docker и Docker Compose
./common/setup_docker.sh

# Создание сетей Docker
docker network create monitoring
docker network create logging

# Запуск сервисов через Docker Compose
docker-compose -f vm3/docker-compose.yml up -d
