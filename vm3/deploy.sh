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

docker-compose up -d --build

# Долгое ожидание для ELK
sleep 30

echo "Сервисы VM3:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo "Доступные интерфейсы:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Kibana: http://localhost:5601"

