#!/bin/bash

echo "Kafka Cluster Status:"
echo "===================="

# Check if servers are running
for i in 1 2 3; do
    pid_file="kafka-server-$i.pid"
    if [ -f $pid_file ]; then
        pid=$(cat $pid_file)
        if ps -p $pid > /dev/null; then
            echo "✓ Server $i: Running (PID: $pid)"
        else
            echo "✗ Server $i: Not running (stale PID file)"
            rm -f $pid_file
        fi
    else
        echo "✗ Server $i: Not running"
    fi
done

echo ""
echo "Broker endpoints:"
echo "- Server 1: localhost:9093"
echo "- Server 2: localhost:9097"
echo "- Server 3: localhost:9098"
