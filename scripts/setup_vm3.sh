#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y git docker.io docker-compose

# Increase virtual memory for Elasticsearch
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Clone repository
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Create necessary directories
mkdir -p prometheus filebeat logstash
chmod -R 777 prometheus filebeat logstash

# Start monitoring and ELK services
docker-compose up -d prometheus grafana elasticsearch logstash kibana filebeat

echo "Monitoring services started:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Kibana: http://localhost:5601"
echo ""
echo "To setup Grafana:"
echo "1. Login to Grafana"
echo "2. Add Prometheus datasource (URL: http://prometheus:9090)"
echo "3. Import dashboard ID 1860 for MySQL monitoring"
