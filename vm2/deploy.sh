#!/bin/bash

# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Останавливаем конфликтующие сервисы
sudo systemctl stop apache2 nginx || true
sudo systemctl stop unattended-upgrades

# Очищаем блокировки
sudo rm -f /var/lib/dpkg/lock-frontend
sudo rm -f /var/lib/dpkg/lock

# Установка Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Настройка прав
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl restart docker

# Подготовка директорий
mkdir -p www
echo "<h1>VM2 Apache Service</h1><p>Host: $(hostname)</p>" > www/index.html
sudo chown -R $USER:$USER www

# Запуск сервисов
docker-compose down
docker-compose up -d --build

# Ждем инициализации
sleep 10

# Проверка
echo "Проверка сервисов:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
curl -v http://localhost || echo "Проверка Apache не удалась"

# Возвращаем системные сервисы
sudo systemctl start unattended-upgrades
