#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Настройка репликации MySQL Slave
sudo mkdir -p /etc/mysql/conf.d
echo "[mysqld]
server-id = 2
log_bin = mysql-bin
binlog_format = ROW
relay-log = mysql-relay-bin
log-slave-updates = 1
read-only = 1" | sudo tee /etc/mysql/conf.d/replication.cnf

# Клонирование репозитория
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Запуск сервисов для VM2
sudo docker compose up -d apache2 mysql_slave

# Ждем полного запуска контейнеров
echo "Ожидание запуска контейнеров..."
while ! sudo docker ps | grep -q "otus2025-mysql_slave-1"; do
    sleep 5
done

# Дополнительное ожидание для инициализации MySQL
sleep 20

# Получение master позиции
read -p "Введите MASTER_LOG_FILE (из вывода на VM1, например mysql-bin.000001): " MASTER_LOG_FILE
read -p "Введите MASTER_LOG_POS (из вывода на VM1, например 1234): " MASTER_LOG_POS

# Настройка репликации на slave
sudo docker exec otus2025-mysql_slave-1 mysql -uroot -proot_password -e "
STOP SLAVE;
CHANGE MASTER TO
MASTER_HOST='192.168.140.132',
MASTER_USER='repl_user',
MASTER_PASSWORD='repl_password',
MASTER_LOG_FILE='$MASTER_LOG_FILE',
MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;"

# Проверка статуса репликации
echo "Статус репликации:"
sudo docker exec otus2025-mysql_slave-1 mysql -uroot -proot_password -e "SHOW SLAVE STATUS\G"
