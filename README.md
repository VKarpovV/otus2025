1. Описание проекта

Проект представляет собой автоматизированное развертывание распределенной инфраструктуры на трех виртуальных машинах с использованием Docker и Docker Compose. Инфраструктура включает:

    VM1 (192.168.140.132): Nginx (балансировщик нагрузки), Apache1, MySQL Master

    VM2 (192.168.140.133): Apache2, MySQL Slave

    VM3 (192.168.140.134): Prometheus, Grafana, ELK-стек (Elasticsearch, Logstash, Kibana)

2. Развертывание на VM* (основной сервер)
Шаг 1: Клонирование репозитория

git clone https://github.com/VKarpovV/otus2025.git

Шаг 2: Запуск скрипта

chmod +x setup_vm*.sh
./setup_vm*.sh
