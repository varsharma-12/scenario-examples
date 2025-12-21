# Step 1: Install Strimzi Operator

The Strimzi operator manages Kafka clusters using Kubernetes Custom Resource Definitions (CRDs).

## Create Kafka Namespace

First, create a dedicated namespace for Kafka:
````bash
kubectl create namespace kafka
````{{exec}}

Verify the namespace:
````bash
kubectl get namespaces
````{{exec}}

## Install Strimzi Operator

Download and apply the Strimzi installation files:
````bash
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
````{{exec}}

This command installs:
- Custom Resource Definitions (CRDs) for Kafka, KafkaTopic, KafkaUser, etc.
- The Strimzi Cluster Operator deployment
- Required RBAC permissions

## Verify Installation

Watch the operator pod start up:
``````````bash
kubectl get pods -n kafka -w
`````````{{exec}}

Press `Ctrl+C` to stop watching once the pod shows `Running` status.

Check the operator logs:
````````bash
kubectl logs deployment/strimzi-cluster-operator -n kafka -f
```````{{exec}}

You should see logs indicating the operator is ready. Press `Ctrl+C` to exit.

## Explore Custom Resources

List the new CRDs installed by Strimzi:
``````bash
kubectl get crd | grep strimzi
`````{{exec}}

You should see:
- `kafkas.kafka.strimzi.io`
- `kafkatopics.kafka.strimzi.io`
- `kafkausers.kafka.strimzi.io`
- `kafkaconnects.kafka.strimzi.io`
- And more!

✅ **Checkpoint**: The Strimzi operator is now running and ready to manage Kafka clusters!
`````
