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

# Остановите контейнер, если запущен
sudo docker stop otus2025-mysql_master-1

# Создайте корректный конфигурационный файл
echo "[mysqld]
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
binlog_do_db = mydb
bind_address = 0.0.0.0" | sudo tee /etc/mysql/conf.d/replication.cnf

# Запустите контейнер заново
sudo docker start otus2025-mysql_master-1

# Дождитесь полной инициализации (30 секунд)
sleep 30

# Получите актуальные данные бинарного лога (используем новый синтаксис)
MASTER_DATA=$(sudo docker exec otus2025-mysql_master-1 mysql -uroot -proot_password -e "SHOW BINARY LOG STATUS\G")
MASTER_LOG_FILE=$(echo "$MASTER_DATA" | grep "File" | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_DATA" | grep "Position" | awk '{print $2}')

# Настройте пользователя репликации
sudo docker exec otus2025-mysql_master-1 mysql -uroot -proot_password -e "
CREATE USER IF NOT EXISTS 'repl_user'@'%' IDENTIFIED BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;"

# Выведите данные для VM2
echo "ДЛЯ НАСТРОЙКИ VM2 ВВЕДИТЕ СЛЕДУЮЩИЕ ДАННЫЕ:"
echo "MASTER_LOG_FILE: $MASTER_LOG_FILE"
echo "MASTER_LOG_POS: $MASTER_LOG_POS"
