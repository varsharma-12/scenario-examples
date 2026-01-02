# Step 3: Deploy Kafka with KRaft (Separate Controllers and Brokers)

Now let's deploy Kafka using KRaft mode with dedicated controller and broker nodes - no ZooKeeper required!

This tutorial refers the examples from https://github.com/confluentinc/confluent-kubernetes-examples/tree/master/quickstart-deploy/kraft-quickstart

## Understanding KRaft Architecture

In this deployment, we'll use separate roles:
- **Controllers**: Dedicated nodes for cluster metadata and leader election
- **Brokers**: Dedicated nodes for handling client connections and data storage

This separation provides better resource isolation and scalability for production environments.

## Create KRaft Controller Configuration

First, let's create the controller configuration:
````bash
cat <<EOF > kafka-controller.yaml
apiVersion: platform.confluent.io/v1beta1
kind: KafkaController
metadata:
  name: kafkacontroller
  namespace: confluent
spec:
  replicas: 3
  image:
    application: docker.io/confluentinc/cp-server:7.9.0
    init: confluentinc/confluent-init-container:2.11.0
  dataVolumeCapacity: 10Gi
  listeners:
    controller:
      enabled: true
      port: 9073
  metricReporter:
    enabled: false
EOF
````{{exec}}

## Create Kafka Broker Configuration

Now, create the broker configuration that references the controllers:
````bash
cat <<EOF > kafka-broker.yaml
apiVersion: platform.confluent.io/v1beta1
kind: Kafka
metadata:
  name: kafka
  namespace: confluent
spec:
  replicas: 3
  image:
    application: docker.io/confluentinc/cp-server:7.9.0
    init: confluentinc/confluent-init-container:2.11.0
  dataVolumeCapacity: 10Gi
  metricReporter:
    enabled: false
  listeners:
    internal:
      enabled: true
      port: 9092
  dependencies:
    kafkaController:
      clusterRef:
        name: kafkacontroller
EOF
````{{exec}}

## Review the Configurations

View the controller configuration:
````bash
cat kafka-controller.yaml
````{exec}}

View the broker configuration:
````bash
cat kafka-broker.yaml
````{{exec}}

**Key architecture points:**
- **3 Controllers** - Dedicated metadata management
- **3 Brokers** - Dedicated data handling
- **No ZooKeeper** - KRaft consensus protocol
- **Persistent storage** - 10Gi per node

## Deploy KRaft Controllers

First, deploy the controllers:
````bash
kubectl apply -f kafka-controller.yaml
````{{exec}}

## Monitor Controller Deployment

Watch the controller pods being created:
````bash
kubectl get pods -n confluent -l app=kafkacontroller -w
````{{exec}}

Wait until all three controller pods show `Running` and `1/1` ready. This takes 2-3 minutes. Press `Ctrl+C` once ready.

## Verify Controllers are Ready

Check controller status:
````bash
kubectl get kafkacontroller -n confluent
````{{exec}}
````bash
kubectl get pods -n confluent -l app=kafkacontroller
````{{exec}}

All three controller pods should be running.

## Deploy Kafka Brokers

Now deploy the brokers:
````bash
kubectl apply -f kafka-broker.yaml
````{{exec}}

## Monitor Broker Deployment

Watch the broker pods being created:
````bash
kubectl get pods -n confluent -l app=kafka -w
````{{exec}}

Wait until all three broker pods show `Running` and `1/1` ready. This takes 3-5 minutes. Press `Ctrl+C` once ready.

**Why it takes time:**
- Controller quorum formation
- Cluster ID generation
- Metadata synchronization
- Persistent volumes binding
- Broker registration with controllers

## Verify Complete Deployment

Check all Kafka resources:
````bash
kubectl get kafkacontroller,kafka -n confluent
````{{exec}}

View all pods:
````bash
kubectl get pods -n confluent
````{{exec}}

You should see:
- 3 `kafkacontroller-*` pods
- 3 `kafka-*` pods

All should be in `Running` state with `1/1` ready.

## View Services

Check the services created:
````bash
kubectl get svc -n confluent
````{exec}}

Notice the separate services:
- `kafkacontroller` - Controller endpoints
- `kafka` - Broker endpoints
- **No ZooKeeper service** - KRaft eliminates this dependency!

## View All Confluent Resources

List all Confluent Platform resources:
````bash
kubectl get confluent -n confluent
````{{exec}}

## Verify KRaft Cluster Metadata

Check the cluster metadata from a broker:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-metadata-quorum --bootstrap-server kafka:9092 describe --status
````{{exec}}

This shows the controller quorum status and confirms KRaft mode is active.

## View Controller Logs (Optional)

Check controller logs to see the quorum formation:
````bash
kubectl logs -n confluent kafkacontroller-0 --tail=20
````{{exec}}

## View Broker Logs (Optional)

Check broker logs to see the connection to controllers:
````bash
kubectl logs -n confluent kafka-0 --tail=20
````{{exec}}

## Verify Cluster Topology

Get detailed information about the cluster:
````bash
kubectl describe kafka kafka -n confluent
````{{exec}}

Look for the `Status` section showing the cluster is ready.

✅ **Success!** You've deployed a production-ready Kafka cluster with:
- 3 dedicated KRaft controllers for metadata management
- 3 dedicated brokers for data handling
- No ZooKeeper dependency
- Persistent storage for durability

This architecture provides better resource isolation and is recommended for production deployments.
```
