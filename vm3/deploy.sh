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

# Останавливаем автоматические обновления
sudo systemctl stop unattended-upgrades

# Очищаем возможные блокировки
sudo rm -f /var/lib/dpkg/lock-frontend
sudo rm -f /var/lib/dpkg/lock

# Установка Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Добавляем пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Перезапускаем Docker
sudo systemctl restart docker

# Запуск сервисов
docker-compose down
docker-compose up -d

# Даем время на запуск сервисов
sleep 25

# Проверка
echo "Сервисы запущены:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000"
echo "- Kibana: http://localhost:5601"

# Проверка контейнеров
docker ps --format "table {{.Names}}\t{{.Status}}"
