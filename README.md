# apache-kafka-course

This repository is for the Apache Kafka Course

Install Kafka 4.0.0 Linux Mint
Повна процедура інсталяції крок за кроком:

Перевірте наявність Java:
bashjava -version
Якщо не встановлено, встановіть:
bashsudo apt update
sudo apt install default-jdk

Створіть каталог і завантажте Kafka:
bashmkdir -p ~/kafka
cd ~/kafka
wget https://downloads.apache.org/kafka/3.6.1/kafka_2.13-3.6.1.tgz

Розпакуйте архів:
bashtar -xzf kafka_2.13-3.6.1.tgz

Створення конфігурації для KRaft

Створіть директорію kraft (якщо її немає):
bashmkdir -p ~/kafka/kafka_2.13-4.0.0/config/kraft

Створіть конфігураційний файл:
bashvi ~/kafka/kafka_2.13-4.0.0/config/kraft/server.properties

Додайте наступні налаштування до файлу:
properties# KRaft specific configurations
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@localhost:9093

# Listener configurations

listeners=PLAINTEXT://:9092,CONTROLLER://:9093
advertised.listeners=PLAINTEXT://localhost:9092
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
inter.broker.listener.name=PLAINTEXT
controller.listener.names=CONTROLLER

# Log configurations

log.dirs=/tmp/kraft-combined-logs

# Other configurations

num.partitions=1
default.replication.factor=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

Альтернативний підхід - модифікація існуючого server.properties
Якщо ви віддаєте перевагу використанню існуючого файлу конфігурації:

Скопіюйте існуючий файл як основу:
bashcp ~/kafka/kafka_2.13-4.0.0/config/server.properties ~/kafka/kafka_2.13-4.0.0/config/kraft-server.properties

Змініть конфігурацію для KRaft:
bashvi ~/kafka/kafka_2.13-4.0.0/config/kraft-server.properties

Додайте/оновіть наступні параметри:
propertiesprocess.roles=broker,controller
node.id=1
controller.quorum.voters=1@localhost:9093
listeners=PLAINTEXT://:9092,CONTROLLER://:9093
advertised.listeners=PLAINTEXT://localhost:9092
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
inter.broker.listener.name=PLAINTEXT
controller.listener.names=CONTROLLER
log.dirs=/tmp/kraft-combined-logs

Запуск Kafka з модифікованою конфігурацією

Форматування сховища:
bashbin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft-server.properties

Запуск сервера:
bashbin/kafka-server-start.sh config/kraft-server.properties
