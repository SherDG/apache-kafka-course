#!/bin/bash

# cluster-info.sh - Get detailed information about Kafka cluster

echo "Kafka Cluster Information"
echo "========================"

# Function to check if a broker is reachable
check_broker() {
    local broker=$1
    local port=$2
    
    if timeout 3 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
        echo "✓ Broker reachable at localhost:$port"
        return 0
    else
        echo "✗ Broker not reachable at localhost:$port"
        return 1
    fi
}

# Check broker connectivity
echo "1. Broker Connectivity:"
echo "----------------------"
check_broker 1 9093
check_broker 2 9097  
check_broker 3 9098

echo ""

# Get broker IDs from configuration
echo "2. Configured Broker IDs:"
echo "------------------------"
for i in 1 2 3; do
    if [ -f "config/server$i.properties" ]; then
        node_id=$(grep "^node.id=" "config/server$i.properties" | cut -d'=' -f2)
        port=$(grep "^listeners=.*PLAINTEXT" "config/server$i.properties" | sed 's/.*PLAINTEXT:\/\/:\([0-9]*\).*/\1/')
        echo "Server $i: Node ID = $node_id, Port = $port"
    fi
done

echo ""

# Query cluster metadata
echo "3. Live Cluster Metadata:"
echo "------------------------"
if check_broker 1 9093 > /dev/null 2>&1; then
    echo "Querying cluster via localhost:9093..."
    
    # Try to get broker list using kafka-broker-api-versions
    echo "Available Brokers:"
    if command -v timeout > /dev/null; then
        timeout 10 bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9093 2>/dev/null | head -10
    else
        bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9093 2>/dev/null | head -10
    fi
    
    echo ""
    
    # Get controller information
    echo "Controller Information:"
    timeout 10 bin/kafka-metadata.sh --bootstrap-server localhost:9093 --list 2>/dev/null | grep -i controller || echo "Controller info not available"
    
else
    echo "Cannot connect to any broker to query live metadata"
fi

echo ""

# Show internal topic information (reveals broker participation)
echo "4. Internal Topics (shows active brokers):"
echo "------------------------------------------"
if check_broker 1 9093 > /dev/null 2>&1; then
    echo "Consumer offsets topic replicas:"
    timeout 10 bin/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic __consumer_offsets 2>/dev/null | head -5
else
    echo "Cannot connect to query topics"
fi

echo ""

# Show cluster ID
echo "5. Cluster Identity:"
echo "-------------------"
for i in 1 2 3; do
    meta_file="/tmp/kraft-combined-logs-$i/meta.properties"
    if [ -f "$meta_file" ]; then
        echo "Server $i metadata:"
        grep "cluster.id" "$meta_file" 2>/dev/null || echo "  Cluster ID not found"
        grep "node.id" "$meta_file" 2>/dev/null || echo "  Node ID not found"
        echo ""
    fi
done
