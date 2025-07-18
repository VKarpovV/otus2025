#!/bin/bash

# Переход в директорию скрипта
cd "$(dirname "$0")"

# Установка Docker
../common/setup_docker.sh

# Очистка предыдущих контейнеров
docker-compose down 2>/dev/null

# Запуск сервисов
docker-compose up -d --build

# Долгое ожидание для ELK
sleep 30

# Проверка
echo "Статус сервисов VM3:"
docker compose ps
echo "Доступные интерфейсы:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Kibana: http://localhost:5601"
