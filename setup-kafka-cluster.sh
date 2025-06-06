#!/bin/bash

# setup-kafka-cluster.sh - Sets up 3-node Kafka cluster configuration files

echo "Setting up Kafka 3-node cluster configuration..."

# Create config directory if it doesn't exist
mkdir -p config

# Server 1 Configuration
cat > config/server1.properties << 'EOF'
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.

############################# Server Basics #############################
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@localhost:9094,2@localhost:9095,3@localhost:9096

############################# Socket Server Settings #############################
listeners=PLAINTEXT://:9093,CONTROLLER://:9094
inter.broker.listener.name=PLAINTEXT
advertised.listeners=PLAINTEXT://localhost:9093
controller.listener.names=CONTROLLER
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT

# Network threads
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

############################# Log Basics #############################
log.dirs=/tmp/kraft-combined-logs-1
num.partitions=1
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings #############################
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=2

############################# Log Retention Policy #############################
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000

############################# Group Coordinator Settings #############################
group.initial.rebalance.delay.ms=0
EOF

# Server 2 Configuration
cat > config/server2.properties << 'EOF'
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.

############################# Server Basics #############################
process.roles=broker,controller
node.id=2
controller.quorum.voters=1@localhost:9094,2@localhost:9095,3@localhost:9096

############################# Socket Server Settings #############################
listeners=PLAINTEXT://:9097,CONTROLLER://:9095
inter.broker.listener.name=PLAINTEXT
advertised.listeners=PLAINTEXT://localhost:9097
controller.listener.names=CONTROLLER
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT

# Network threads
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

############################# Log Basics #############################
log.dirs=/tmp/kraft-combined-logs-2
num.partitions=1
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings #############################
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=2

############################# Log Retention Policy #############################
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000

############################# Group Coordinator Settings #############################
group.initial.rebalance.delay.ms=0
EOF

# Server 3 Configuration
cat > config/server3.properties << 'EOF'
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.

############################# Server Basics #############################
process.roles=broker,controller
node.id=3
controller.quorum.voters=1@localhost:9094,2@localhost:9095,3@localhost:9096

############################# Socket Server Settings #############################
listeners=PLAINTEXT://:9098,CONTROLLER://:9096
inter.broker.listener.name=PLAINTEXT
advertised.listeners=PLAINTEXT://localhost:9098
controller.listener.names=CONTROLLER
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT

# Network threads
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

############################# Log Basics #############################
log.dirs=/tmp/kraft-combined-logs-3
num.partitions=1
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings #############################
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=2

############################# Log Retention Policy #############################
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000

############################# Group Coordinator Settings #############################
group.initial.rebalance.delay.ms=0
EOF

echo "Configuration files created successfully!"
echo "- Server 1: config/server1.properties (PLAINTEXT: 9093, CONTROLLER: 9094)"
echo "- Server 2: config/server2.properties (PLAINTEXT: 9097, CONTROLLER: 9095)"
echo "- Server 3: config/server3.properties (PLAINTEXT: 9098, CONTROLLER: 9096)"

# ==========================================
# format-cluster.sh - Formats the cluster storage
# ==========================================

cat > format-cluster.sh << 'EOF'
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
EOF

chmod +x format-cluster.sh

# ==========================================
# start-cluster.sh - Starts all 3 servers
# ==========================================

cat > start-cluster.sh << 'EOF'
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
EOF

chmod +x start-cluster.sh

# ==========================================
# stop-cluster.sh - Stops all servers
# ==========================================

cat > stop-cluster.sh << 'EOF'
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
EOF

chmod +x stop-cluster.sh

# ==========================================
# status-cluster.sh - Check cluster status
# ==========================================

cat > status-cluster.sh << 'EOF'
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
EOF

chmod +x status-cluster.sh

# Create logs directory
mkdir -p logs

echo ""
echo "Setup complete! Next steps:"
echo "1. Format the cluster storage: ./format-cluster.sh"
echo "2. Start the cluster: ./start-cluster.sh"
echo "3. Check status: ./status-cluster.sh"
echo "4. Stop the cluster: ./stop-cluster.sh"
