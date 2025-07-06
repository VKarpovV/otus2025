#!/bin/bash
set -e

sudo apt update
sudo apt install -y git ansible sshpass

git clone https://github.com/VKarpovV/otus2025.git
cd otus2025

ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -b --ask-become-pass

echo "Развертывание успешно завершено!"
