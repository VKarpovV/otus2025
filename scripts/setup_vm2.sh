#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y git docker.io docker-compose

# Clone repository
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Start services for VM2 (apache2, mysql_slave)
docker-compose up -d apache2 mysql_slave

# Configure MySQL slave
sleep 30  # Wait for MySQL to start

# Get master container IP (assuming they're on same host network)
MASTER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql_master)

docker exec mysql_slave mysql -uroot -prootpass -e "
STOP SLAVE;
CHANGE MASTER TO
MASTER_HOST='$MASTER_IP',
MASTER_USER='repl_user',
MASTER_PASSWORD='replpass',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=156;
START SLAVE;
"

echo "MySQL Slave setup complete"
