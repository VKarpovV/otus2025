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

# Подготовка директорий
mkdir -p www
echo "<h1>VM1 Apache Service</h1>" > www/index.html
chmod -R 755 www

# Запуск сервисов с ожиданием
docker-compose up -d --build

# Ждем инициализации Apache
for i in {1..10}; do
    if docker exec vm1_apache_1 curl -s http://localhost >/dev/null; then
        break
    fi
    sleep 3
done

# Проверка
echo "Проверка сервисов VM1:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
curl -I http://localhost || echo "Nginx недоступен"
