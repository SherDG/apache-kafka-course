#!/bin/bash
cd ~/kafka/kafka_2.13-4.0.0

# Generate a cluster ID if needed (you can use the same ID each time)
CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)

# Format the storage
bin/kafka-storage.sh format -t $CLUSTER_ID -c config/kraft/server.properties

# Start the Kafka server
bin/kafka-server-start.sh config/kraft/server.properties
