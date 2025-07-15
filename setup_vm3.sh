#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Увеличение vm.max_map_count для Elasticsearch
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Клонирование репозитория
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Запуск сервисов для VM3
sudo docker compose up -d prometheus grafana elk

# Настройка Grafana
echo "Waiting for Grafana to start..."
sleep 30
sudo docker exec -it grafana grafana-cli plugins install grafana-piechart-panel
sudo docker restart grafana

echo "Setup completed on VM3"
echo "Access services:"
echo "- Prometheus: http://192.168.140.134:9090"
echo "- Grafana: http://192.168.140.134:3000 (admin/admin)"
echo "- Kibana: http://192.168.140.134:5601"
