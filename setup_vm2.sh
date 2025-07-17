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

# Остановите контейнер, если запущен
sudo docker stop otus2025-mysql_slave-1

# Создайте конфигурационный файл
echo "[mysqld]
server-id = 2
log_bin = mysql-bin
binlog_format = ROW
relay-log = mysql-relay-bin
log-slave-updates = 1
read-only = 1" | sudo tee /etc/mysql/conf.d/replication.cnf

# Запустите контейнер заново
sudo docker start otus2025-mysql_slave-1

# Дождитесь запуска (30 секунд)
sleep 30

# Настройте репликацию (используем новый синтаксис MySQL 8.4+)
sudo docker exec otus2025-mysql_slave-1 mysql -uroot -proot_password -e "
STOP REPLICA;
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='192.168.140.132',
SOURCE_USER='repl_user',
SOURCE_PASSWORD='repl_password',
SOURCE_LOG_FILE='$MASTER_LOG_FILE',
SOURCE_LOG_POS=$MASTER_LOG_POS;
START REPLICA;"

# Проверьте статус
sudo docker exec otus2025-mysql_slave-1 mysql -uroot -proot_password -e "SHOW REPLICA STATUS\G" | grep -E "Replica_IO_Running|Replica_SQL_Running|Last_Error"
