#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker (оставляем ваш оригинальный метод)
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Настройка репликации MySQL Master (полностью сохраняем вашу логику)
sudo mkdir -p /etc/mysql/conf.d
echo "[mysqld]
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
binlog_do_db = mydb" | sudo tee /etc/mysql/conf.d/replication.cnf

# Клонирование репозитория
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Добавляем подготовку тестовой страницы Apache (НОВОЕ)
mkdir -p apache1_html
echo "<h1>Apache1 on VM1 (192.168.140.132)</h1>" > apache1_html/index.html

# Запуск сервисов для VM1
sudo docker compose up -d nginx apache1 mysql_master

# Остановка контейнера для корректировки конфигурации
sudo docker stop otus2025-mysql_master-1

# Создание корректного конфигурационного файла
echo "[mysqld]
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
binlog_do_db = mydb
bind_address = 0.0.0.0" | sudo tee /etc/mysql/conf.d/replication.cnf

# Запуск контейнера заново
sudo docker start otus2025-mysql_master-1

# Ожидание инициализации
sleep 30

# Получение данных бинарного лога
MASTER_DATA=$(sudo docker exec otus2025-mysql_master-1 mysql -uroot -proot_password -e "SHOW BINARY LOG STATUS\G")
MASTER_LOG_FILE=$(echo "$MASTER_DATA" | grep "File" | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_DATA" | grep "Position" | awk '{print $2}')

# Настройка пользователя репликации
sudo docker exec otus2025-mysql_master-1 mysql -uroot -proot_password -e "
CREATE USER IF NOT EXISTS 'repl_user'@'%' IDENTIFIED BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;"

# Вывод данных для VM2
echo "ДЛЯ НАСТРОЙКИ VM2 ВВЕДИТЕ СЛЕДУЮЩИЕ ДАННЫЕ:"
echo "MASTER_LOG_FILE: $MASTER_LOG_FILE"
echo "MASTER_LOG_POS: $MASTER_LOG_POS"

# Добавляем информацию о балансировке (НОВОЕ)
echo "=== Проверка балансировки ==="
echo "Запросы к Nginx будут распределяться между:"
echo "1. Apache1 на VM1 (192.168.140.132:8080)"
echo "2. Apache2 на VM2 (192.168.140.133:8080)"
echo "Проверить: curl http://192.168.140.132"
