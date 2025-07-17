#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y git docker.io docker-compose

# Clone repository
git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

# Start monitoring services
docker-compose up -d prometheus grafana

echo "Monitoring services started:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
