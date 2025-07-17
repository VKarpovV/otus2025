#!/bin/bash

# Функция для проверки доступности порта
wait_for_port() {
    host=$1
    port=$2
    timeout=30
    
    echo "Waiting for $host:$port..."
    until nc -z $host $port || [ $timeout -le 0 ]; do
        sleep 1
        ((timeout--))
    done
    
    if [ $timeout -le 0 ]; then
        echo "Timeout waiting for $host:$port"
        return 1
    fi
    return 0
}

# Функция для проверки статуса Docker контейнера
check_container_status() {
    container_name=$1
    timeout=60
    
    echo "Checking $container_name status..."
    until [ "$(docker inspect -f '{{.State.Running}}' $container_name 2>/dev/null)" == "true" ] || [ $timeout -le 0 ]; do
        sleep 1
        ((timeout--))
    done
    
    if [ $timeout -le 0 ]; then
        echo "Timeout waiting for $container_name to start"
        return 1
    fi
    return 0
}

# Функция для настройки firewall
configure_firewall() {
    ports=("$@")
    
    if command -v ufw &> /dev/null; then
        for port in "${ports[@]}"; do
            sudo ufw allow $port
        done
        sudo ufw --force enable
    elif command -v firewall-cmd &> /dev/null; then
        for port in "${ports[@]}"; do
            sudo firewall-cmd --permanent --add-port=$port/tcp
        done
        sudo firewall-cmd --reload
    fi
}
