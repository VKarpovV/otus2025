#!/bin/bash

MASTER_IP="192.168.140.132"
SLAVE_IP="192.168.140.133"
MYSQL_ROOT_PASSWORD="securepassword"

# 1. Настройка SSH-ключей
ssh-copy-id $USER@$MASTER_IP
ssh-copy-id $USER@$SLAVE_IP

# 2. Настройка мастера (VM1)
ssh $USER@$MASTER_IP <<EOF
docker exec -i vm1_mysql-master_1 mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
CREATE USER 'replica'@'$SLAVE_IP' IDENTIFIED BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'$SLAVE_IP';
FLUSH PRIVILEGES;
"
EOF

# 3. Получение позиции мастера
MASTER_STATUS=$(ssh $USER@$MASTER_IP "docker exec -i vm1_mysql-master_1 mysql -uroot -p$MYSQL_ROOT_PASSWORD -e 'SHOW MASTER STATUS'")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | awk 'NR==2 {print $1}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | awk 'NR==2 {print $2}')

# 4. Настройка слейва (VM2)
ssh $USER@$SLAVE_IP <<EOF
docker exec -i vm2_mysql-slave_1 mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
STOP SLAVE;
CHANGE MASTER TO
MASTER_HOST='$MASTER_IP',
MASTER_USER='replica',
MASTER_PASSWORD='replica_password',
MASTER_LOG_FILE='$MASTER_LOG_FILE',
MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
"
EOF

# 5. Проверка
echo "Проверка репликации:"
ssh $USER@$SLAVE_IP "docker exec -i vm2_mysql-slave_1 mysql -uroot -p$MYSQL_ROOT_PASSWORD -e 'SHOW SLAVE STATUS\G' | grep -E 'Slave_IO_Running|Slave_SQL_Running'"
