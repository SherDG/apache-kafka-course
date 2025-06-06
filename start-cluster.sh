#!/bin/bash

echo "Starting Kafka 3-node cluster..."

# Function to start a server
start_server() {
    local server_num=$1
    local config_file=$2
    local log_file=$3
    
    echo "Starting Kafka Server $server_num..."
    nohup bin/kafka-server-start.sh $config_file > $log_file 2>&1 &
    local pid=$!
    echo "Server $server_num started with PID: $pid"
    echo $pid > kafka-server-$server_num.pid
    sleep 3
}

# Start all servers
start_server 1 config/server1.properties logs/kafka-server-1.log
start_server 2 config/server2.properties logs/kafka-server-2.log
start_server 3 config/server3.properties logs/kafka-server-3.log

echo "All servers started!"
echo "Broker endpoints:"
echo "- Server 1: localhost:9093"
echo "- Server 2: localhost:9097"
echo "- Server 3: localhost:9098"
echo ""
echo "Check logs in the logs/ directory"
echo "To stop the cluster, run: ./stop-cluster.sh"
