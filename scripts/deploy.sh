#!/bin/bash

if ! command -v git &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y git
fi

if [ ! -d "/opt/otus2025" ]; then
    sudo git clone https://github.com/VKarpovV/otus2025.git /opt/otus2025
else
    cd /opt/otus2025
    sudo git pull
fi

sudo chmod +x /opt/otus2025/scripts/*.sh

case $(hostname -I | awk '{print $1}') in
    192.168.140.132)
        echo "Setting up NGINX frontend"
        sudo /opt/otus2025/scripts/setup_nginx.sh
        ;;
    192.168.140.133)
        echo "Setting up Apache + MySQL"
        sudo /opt/otus2025/scripts/setup_apache.sh
        sudo /opt/otus2025/scripts/setup_mysql.sh master
        ;;
    192.168.140.134)
        echo "Setting up Monitoring + ELK"
        sudo /opt/otus2025/scripts/setup_prometheus.sh
        sudo /opt/otus2025/scripts/setup_grafana.sh
        sudo /opt/otus2025/scripts/setup_elk.sh
        sudo /opt/otus2025/scripts/setup_ftp.sh
        ;;
    *)
        echo "Unknown IP address"
        exit 1
        ;;
esac

sudo /opt/otus2025/scripts/setup_filebeat.sh

echo "Deployment completed successfully!"
