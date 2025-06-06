#!/bin/bash

echo "Stopping Kafka cluster..."

# Function to stop a server
stop_server() {
    local server_num=$1
    local pid_file="kafka-server-$server_num.pid"
    
    if [ -f $pid_file ]; then
        local pid=$(cat $pid_file)
        echo "Stopping Kafka Server $server_num (PID: $pid)..."
        kill $pid
        rm -f $pid_file
        echo "Server $server_num stopped"
    else
        echo "PID file for Server $server_num not found"
    fi
}

# Stop all servers
stop_server 1
stop_server 2
stop_server 3

echo "All servers stopped!"
