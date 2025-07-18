# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Останавливаем конфликтующие сервисы
sudo systemctl stop apache2 nginx || true
sudo systemctl stop unattended-upgrades
sudo rm -f /var/lib/dpkg/lock-frontend
sudo rm -f /var/lib/dpkg/lock

# Установка Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Настройка прав
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl restart docker

# Подготовка директорий
mkdir -p www
echo "<h1>VM1 Apache Service</h1><p>Host: $(hostname)</p>" > www/index.html
chmod -R 755 www

# Запуск сервисов
docker-compose down
docker-compose up -d --build

# Ждем инициализации
echo "Ожидаем запуск сервисов..."
sleep 15

# Проверка
echo "Проверка сервисов:"
docker ps -a
curl -v http://localhost || echo "Проверка Nginx не удалась"
docker exec -it vm1_apache_1 curl -s http://localhost || echo "Проверка Apache изнутри не удалась"

# Возвращаем системные сервисы
sudo systemctl start unattended-upgrades
