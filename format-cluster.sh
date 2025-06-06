#!/bin/bash

echo "Generating cluster UUID..."
CLUSTER_UUID=$(bin/kafka-storage.sh random-uuid)
echo "Cluster UUID: $CLUSTER_UUID"

echo "Formatting storage for all nodes..."
bin/kafka-storage.sh format -t $CLUSTER_UUID -c config/server1.properties
bin/kafka-storage.sh format -t $CLUSTER_UUID -c config/server2.properties
bin/kafka-storage.sh format -t $CLUSTER_UUID -c config/server3.properties

echo "Storage formatted successfully!"
echo "You can now start the cluster with: ./start-cluster.sh"
