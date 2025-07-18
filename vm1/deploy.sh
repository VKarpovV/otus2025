#!/bin/bash

# Переход в директорию скрипта
cd "$(dirname "$0")"

# Установка Docker
../common/setup_docker.sh

# Очистка предыдущих контейнеров
docker-compose down 2>/dev/null

# Подготовка директорий
mkdir -p www
echo "<h1>VM1 Apache Service</h1>" > www/index.html
chmod -R 755 www

# Запуск сервисов
docker-compose up -d --build

# Ожидание инициализации
for i in {1..10}; do
    if docker compose ps | grep -q "running"; then
        break
    fi
    sleep 5
done

# Проверка
echo "Статус сервисов VM1:"
docker compose ps
curl -I http://localhost || echo "Nginx недоступен"
