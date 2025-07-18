#!/bin/bash

MASTER_IP="192.168.140.132"
SLAVE_IP="192.168.140.133"

# Настройка мастера
ssh $MASTER_IP "docker exec -i mysql-master mysql -uroot -psecurepassword -e \"
CREATE USER 'replica'@'$SLAVE_IP' IDENTIFIED BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'$SLAVE_IP';
FLUSH PRIVILEGES;
\""

# Получение позиции мастера
MASTER_STATUS=$(ssh $MASTER_IP "docker exec -i mysql-master mysql -uroot -psecurepassword -e 'SHOW MASTER STATUS'")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | awk 'NR==2 {print $1}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | awk 'NR==2 {print $2}')

# Настройка слейва
ssh $SLAVE_IP "docker exec -i mysql-slave mysql -uroot -psecurepassword -e \"
STOP SLAVE;
CHANGE MASTER TO
MASTER_HOST='$MASTER_IP',
MASTER_USER='replica',
MASTER_PASSWORD='replica_password',
MASTER_LOG_FILE='$MASTER_LOG_FILE',
MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
\""

# Проверка статуса репликации
ssh $SLAVE_IP "docker exec -i mysql-slave mysql -uroot -psecurepassword -e 'SHOW SLAVE STATUS\G'"
