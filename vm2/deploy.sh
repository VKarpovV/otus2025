#!/bin/bash

# Автоматическая настройка прав Docker
if ! groups | grep -q docker; then
    sudo usermod -aG docker $USER
    exec sg docker newgrp $(id -gn)  # Перелогин в текущей сессии
fi

# Перезапуск Docker без запроса пароля
sudo systemctl restart docker

# Очистка предыдущих контейнеров
docker-compose down 2>/dev/null

# Переходим в директорию скрипта
cd "$(dirname "$0")"

mkdir -p www
echo "<h1>VM2 Apache Service</h1>" > www/index.html
chmod -R 755 www

docker-compose up -d --build

# Ожидание инициализации
sleep 10

echo "Проверка сервисов VM2:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
curl -I http://localhost:80 || echo "Apache недоступен"
