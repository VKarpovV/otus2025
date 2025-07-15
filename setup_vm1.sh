#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Настройка репликации MySQL Master
sudo mkdir -p /etc/mysql/conf.d
echo "[mysqld]
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
binlog_do_db = mydb" | sudo tee /etc/mysql/conf.d/replication.cnf

# Клонирование репозитория
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Запуск сервисов для VM1
sudo docker compose up -d nginx apache1 mysql_master

# Настройка репликации на master
sudo docker exec -it mysql_master mysql -uroot -proot_password -e "
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;
SHOW MASTER STATUS;"
