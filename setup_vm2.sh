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

# Получение master позиции (нужно ввести данные из вывода SHOW MASTER STATUS на VM1)
read -p "Enter MASTER_LOG_FILE (from VM1): " MASTER_LOG_FILE
read -p "Enter MASTER_LOG_POS (from VM1): " MASTER_LOG_POS

# Настройка репликации на slave
sudo docker exec -it mysql_slave mysql -uroot -proot_password -e "
STOP SLAVE;
CHANGE MASTER TO
MASTER_HOST='192.168.140.132',
MASTER_USER='repl_user',
MASTER_PASSWORD='repl_password',
MASTER_LOG_FILE='$MASTER_LOG_FILE',
MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
SHOW SLAVE STATUS\G"
