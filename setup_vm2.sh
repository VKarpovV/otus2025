#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Клонирование репозитория (если не склонирован)
if [ ! -d "otus2025" ]; then
    git clone https://github.com/VKarpovV/otus2025.git
    cd otus2025 || exit
else
    cd otus2025 || exit
    git pull origin main
fi

# Запуск сервисов для VM2
sudo docker compose up -d apache2 mysql_slave

# Ожидание запуска контейнера MySQL Slave
echo "Ожидание запуска MySQL Slave (30 секунд)..."
while ! sudo docker ps | grep -q "otus2025-mysql_slave-1"; do
    sleep 5
done
sleep 25  # Дополнительное время для инициализации MySQL

# Запрос параметров репликации
echo "Введите параметры, полученные с VM1:"
read -p "MASTER_LOG_FILE (например: binlog.000003): " MASTER_LOG_FILE
read -p "MASTER_LOG_POS (например: 856): " MASTER_LOG_POS

# Настройка репликации с проверкой ошибок
echo "Настройка репликации..."
if ! sudo docker exec otus2025-mysql_slave-1 bash -c "
mysql -uroot -proot_password <<'MYSQL_SCRIPT'
STOP REPLICA;
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='192.168.140.132',
SOURCE_USER='repl_user',
SOURCE_PASSWORD='repl_password',
SOURCE_LOG_FILE='$MASTER_LOG_FILE',
SOURCE_LOG_POS=$MASTER_LOG_POS;
START REPLICA;
MYSQL_SCRIPT"
then
    echo "ОШИБКА: Не удалось настроить репликацию"
    echo "Проверьте логи MySQL:"
    sudo docker logs otus2025-mysql_slave-1 | grep -i error
    exit 1
fi

# Проверка статуса репликации
echo "Проверка статуса репликации..."
STATUS=$(sudo docker exec otus2025-mysql_slave-1 mysql -uroot -proot_password -e "SHOW REPLICA STATUS\G")

if echo "$STATUS" | grep -q "Replica_IO_Running: Yes" && echo "$STATUS" | grep -q "Replica_SQL_Running: Yes"; then
    echo "Репликация успешно настроена!"
    echo "IO Thread: Running"
    echo "SQL Thread: Running"
else
    echo "ОШИБКА: Проблемы с репликацией"
    echo "$STATUS" | grep -E "Replica_IO_Running|Replica_SQL_Running|Last_Error"
    exit 1
fi

# Тестовая проверка
echo "Для теста создайте базу данных на VM1, затем проверьте её наличие здесь:"
echo "sudo docker exec otus2025-mysql_slave-1 mysql -uroot -proot_password -e 'SHOW DATABASES;'"
