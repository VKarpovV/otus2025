#!/bin/bash

# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Очистка возможных блокировок
sudo rm -f /var/lib/dpkg/lock
sudo rm -f /var/lib/dpkg/lock-frontend

# Проверка и установка Docker
if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose
fi

# Настройка прав Docker
sudo usermod -aG docker $USER || true
newgrp docker || true
sudo systemctl restart docker

# Подготовка веб-контента
mkdir -p www
echo "<h1>VM2 Apache Service</h1><p>Host: $(hostname)</p>" > www/index.html
chmod -R 755 www

# Перезапуск сервисов
docker-compose down
docker-compose up -d --build

# Ожидание инициализации
echo "Ожидаем запуск сервисов..."
sleep 15

# Проверка
echo "Статус контейнеров:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "Проверка Apache:"
curl -v http://localhost || echo "Проверка не удалась"
