#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y git docker.io docker-compose

# Clone repository
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Start services for VM1 (nginx, apache1, mysql_master)
docker-compose up -d nginx apache1 mysql_master

# Configure MySQL replication
sleep 30  # Wait for MySQL to start
MASTER_STATUS=$(docker exec mysql_master mysql -uroot -prootpass -e "SHOW MASTER STATUS" | awk 'NR==2')
MASTER_LOG_FILE=$(echo $MASTER_STATUS | awk '{print $1}')
MASTER_LOG_POS=$(echo $MASTER_STATUS | awk '{print $2}')

docker exec mysql_master mysql -uroot -prootpass -e "
CREATE DATABASE mydb;
USE mydb;
CREATE TABLE test (id INT AUTO_INCREMENT PRIMARY KEY, data VARCHAR(255));
"

echo "MySQL Master setup complete. Use these for slave configuration:"
echo "Log File: $MASTER_LOG_FILE"
echo "Log Position: $MASTER_LOG_POS"
