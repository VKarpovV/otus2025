#!/bin/bash

# Переход в директорию скрипта
cd "$(dirname "$0")"

# Установка Docker
../common/setup_docker.sh

# Очистка предыдущих контейнеров
docker-compose down 2>/dev/null

# Подготовка директорий
mkdir -p www
echo "<h1>VM2 Apache Service</h1>" > www/index.html
chmod -R 755 www

# Запуск сервисов
docker-compose up -d --build

# Ожидание инициализации
sleep 10

# Проверка
echo "Статус сервисов VM2:"
docker compose ps
curl -I http://localhost || echo "Apache недоступен"
