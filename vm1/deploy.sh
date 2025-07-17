#!/bin/bash

# Установка зависимостей с проверкой прав
sudo apt-get update
sudo apt-get install -y git curl docker.io docker-compose

# Явный запуск скрипта установки Docker с sudo
sudo bash ./common/setup_docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Создание сетей Docker
docker network create frontend
docker network create backend

# Запуск сервисов через Docker Compose
docker-compose -f vm1/docker-compose.yml up -d

# Настройка репликации MySQL
sudo bash ./common/setup_replication.sh master 192.168.140.132 192.168.140.133
