#!/bin/bash

MASTER_IP="192.168.140.132"
SLAVE_IP="192.168.140.133"
USER="kva"

# 1. Настройка SSH-ключей (если их нет)
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Генерация SSH-ключа..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# 2. Копирование ключей на обе машины
echo "Настройка SSH-доступа к $MASTER_IP..."
ssh-copy-id -o StrictHostKeyChecking=no $USER@$MASTER_IP || {
    echo "Ошибка копирования ключа на $MASTER_IP"
    exit 1
}

echo "Настройка SSH-доступа к $SLAVE_IP..."
ssh-copy-id -o StrictHostKeyChecking=no $USER@$SLAVE_IP || {
    echo "Ошибка копирования ключа на $SLAVE_IP"
    exit 1
}

# 3. Настройка репликации
echo "Настройка MySQL Master на $MASTER_IP..."
ssh $USER@$MASTER_IP "docker exec mysql-master mysql -uroot -psecurepassword -e \"
CREATE USER IF NOT EXISTS 'replica'@'$SLAVE_IP' IDENTIFIED BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'$SLAVE_IP';
FLUSH PRIVILEGES;
\""

# 4. Получение позиции Master
MASTER_STATUS=$(ssh $USER@$MASTER_IP "docker exec mysql-master mysql -uroot -psecurepassword -e 'SHOW MASTER STATUS'")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | awk 'NR==2 {print $1}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | awk 'NR==2 {print $2}')

# 5. Настройка Slave
echo "Настройка MySQL Slave на $SLAVE_IP..."
ssh $USER@$SLAVE_IP "docker exec mysql-slave mysql -uroot -psecurepassword -e \"
STOP SLAVE;
CHANGE MASTER TO
MASTER_HOST='$MASTER_IP',
MASTER_USER='replica',
MASTER_PASSWORD='replica_password',
MASTER_LOG_FILE='$MASTER_LOG_FILE',
MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
\""

# 6. Проверка статуса репликации
echo "Проверка статуса репликации на Slave..."
ssh $USER@$SLAVE_IP "docker exec mysql-slave mysql -uroot -psecurepassword -e 'SHOW SLAVE STATUS\G' | grep -E 'Slave_IO_Running|Slave_SQL_Running'"

echo "Репликация успешно настроена между $MASTER_IP (Master) и $SLAVE_IP (Slave)"
