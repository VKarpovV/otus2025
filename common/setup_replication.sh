#!/bin/bash

ROLE=$1
SLAVE_IP=$2
MASTER_IP=$3

if [ "$ROLE" == "master" ]; then
    # Настройка мастера
    docker exec mysql-master mysql -uroot -psecurepassword -e "
    CREATE USER 'replica'@'$SLAVE_IP' IDENTIFIED BY 'replica_password';
    GRANT REPLICATION SLAVE ON *.* TO 'replica'@'$SLAVE_IP';
    FLUSH PRIVILEGES;
    "
    
    # Получение позиции бинарного лога
    docker exec mysql-master mysql -uroot -psecurepassword -e "SHOW MASTER STATUS" > master_status.txt
    
elif [ "$ROLE" == "slave" ]; then
    # Ожидание готовности мастера
    while ! nc -z $MASTER_IP 3306; do
        sleep 1
    done
    
    # Получение данных с мастера
    MASTER_STATUS=$(ssh $MASTER_IP "cat /path/to/master_status.txt")
    MASTER_LOG_FILE=$(echo $MASTER_STATUS | awk '{print $1}')
    MASTER_LOG_POS=$(echo $MASTER_STATUS | awk '{print $2}')
    
    # Настройка слейва
    docker exec mysql-slave mysql -uroot -psecurepassword -e "
    CHANGE MASTER TO
    MASTER_HOST='$MASTER_IP',
    MASTER_USER='replica',
    MASTER_PASSWORD='replica_password',
    MASTER_LOG_FILE='$MASTER_LOG_FILE',
    MASTER_LOG_POS=$MASTER_LOG_POS;
    START SLAVE;
    "
fi
