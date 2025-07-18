1. Описание проекта

Проект представляет собой автоматизированное развертывание распределенной инфраструктуры на трех виртуальных машинах с использованием Docker и Docker Compose. Инфраструктура включает:

    VM1 (192.168.140.132): Nginx (балансировщик нагрузки), Apache1, MySQL Master

    VM2 (192.168.140.133): Apache2, MySQL Slave

    VM3 (192.168.140.134): Prometheus, Grafana, ELK-стек (Elasticsearch, Logstash, Kibana)

2. Развертывание на VM* (основной сервер)
Шаг 1: Клонирование репозитория

git clone https://github.com/VKarpovV/otus2025.git

Шаг 2: Даем права

chmod +x vm*/deploy.sh

chmod +x common/*.sh

4.Установим зависимости

sudo apt update

sudo apt install -y git curl net-tools

5. Запускаем скрипт

./vm1/deploy.sh  # На VM1

./vm2/deploy.sh  # На VM2

./vm3/deploy.sh  # На VM3

6. Настроим репликацию MySQL между VM1 и VM2, выполните:

   сначала настройте SSH-доступ без пароля:

ssh-keygen

ssh-copy-id kva@192.168.140.132

ssh-copy-id kva@192.168.140.133

 потом запустить скрипт
     
cd ~/otus2025/common

chmod +x setup_replication.sh

./setup_replication.sh


7. Мониторинг

    Prometheus: http://192.168.140.134:9090

    Grafana: http://192.168.140.134:3000 (логин: admin, пароль: admin)

    Kibana: http://192.168.140.134:5601
   ## Автоматическая настройка репликации MySQL

Скрипт `common/setup_replication.sh` автоматически:
1. Генерирует SSH-ключи при их отсутствии
2. Настраивает доступ без пароля между VM1 и VM2
3. Конфигурирует Master и Slave серверы MySQL
