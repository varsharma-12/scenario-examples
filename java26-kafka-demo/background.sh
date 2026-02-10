#!/bin/bash

# Background setup script - prepares the environment while user reads intro

# Wait for Kubernetes to be ready
echo "Waiting for Kubernetes cluster..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Pre-pull heavy images to save time later
echo "Pre-pulling Docker images..."
kubeadm config images pull &

# Install required tools
echo "Installing Maven..."
apt-get update -qq
apt-get install -y maven python3-pip -qq

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install kafka-python --quiet

# Create necessary directories

mkdir -p /root/demo/kafka-streams-demo/

cp -r /root/java26-kafka-demo/* /root/demo/kafka-streams-demo/
touch /tmp/finished_setup


# Extract the demo application if the tar.gz is present
#if [ -f /root/kafka-streams-demo.tar.gz ]; then
 #   echo "Extracting demo application..."
  #  tar -xzf /root/kafka-streams-demo.tar.gz -C /root/demo
#fi


#  Wait for the asset to download
while [ ! -f /root/kafka-streams-demo.tar.gz ]; do
  sleep 1
done

#  Extract
tar -xzf /root/kafka-streams-demo.tar.gz -C /root/demo/kafka-streams-demo/

# 4. Path-Fix: Ensure pom.xml is in the root of the demo folder
POM_PATH=$(find /root/demo/kafka-streams-demo -name pom.xml | head -n 1)
if [ -n "$POM_PATH" ]; then
    ACTUAL_DIR=$(dirname "$POM_PATH")
    if [ "$ACTUAL_DIR" != "/root/demo/kafka-streams-demo" ]; then
        mv "$ACTUAL_DIR"/* /root/demo/kafka-streams-demo/
    fi
fi

# Pre-build Maven dependencies to save time
if [ -d /root/demo/kafka-streams-demo ]; then
    cd /root/demo/kafka-streams-demo
    echo "Pre-downloading Maven dependencies..."
    mvn dependency:resolve dependency:resolve-plugins -q &
fi

echo "Environment setup complete!" > /tmp/setup-complete
