# Step 3: Deploy Kafka with KRaft (Separate Controllers and Brokers)

Now let's deploy Kafka using KRaft mode with dedicated controller and broker nodes - no ZooKeeper required!

## Understanding KRaft Architecture

In this deployment, we'll use separate roles:
- **Controllers**: Dedicated nodes for cluster metadata and leader election
- **Brokers**: Dedicated nodes for handling client connections and data storage

This separation provides better resource isolation and scalability .

## Create KRaft Controller Configuration

First, let's create the controller configuration:
````bash
cat <<EOF > Kraft.yaml
apiVersion: platform.confluent.io/v1beta1
kind: KRaftController
metadata:
  name: kraftcontroller
  namespace: confluent
spec:
  replicas: 1
  image:
    application: docker.io/confluentinc/cp-server:7.9.0
    init: confluentinc/confluent-init-container:2.11.0
  dataVolumeCapacity: 10Gi
EOF
````{{exec}}

## Deploy KRaft Controllers

````bash
kubectl apply -f Kraft.yaml
````{{exec}}

## Watch the controller pods being created:
````bash
kubectl get pods -n confluent -w
````{{exec}}

## Monitor Controller Deployment

Wait until controller pod show `Running` and `1/1` ready. This takes 2-3 minutes. Press `Ctrl+C` once ready.

## Verify Controllers are Ready

Check controller status:
````bash
kubectl get kraftcontroller -n confluent
````{{exec}}
````bash
kubectl get pods -n confluent -l app=kraftcontroller
````{{exec}}

Controller pods should be running.

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
  replicas: 1
  image:
    application: docker.io/confluentinc/cp-server:7.9.0
    init: confluentinc/confluent-init-container:2.11.0
  dataVolumeCapacity: 10Gi
  dependencies:
    kRaftController:
      clusterRef:
        name: kraftcontroller
EOF
````{{exec}}

## Deploy Kafka Brokers

````bash
kubectl apply -f kafka-broker.yaml
````{{exec}}

## Monitor Broker Deployment

Watch the broker pods being created:

````bash
kubectl get pods -n confluent -l app=kafka -w
````{{exec}}

Wait until  broker pod show `Running` and `1/1` ready. This takes 3-5 minutes. Press `Ctrl+C` once ready.


## Verify Complete Deployment

Check all Kafka resources:

````bash
kubectl get all -n confluent
````{{exec}}

View all pods deployed on underlying nodes.

````bash
kubectl get pods  -o wide -n confluent
````{{exec}}


## Verify KRaft Cluster Metadata

Check the cluster metadata from a broker:

````bash
kubectl exec -n confluent kafka-0 -it -- bash
````{{exec}}

````bash
kafka-metadata-quorum --bootstrap-server kafka:9092 describe --status
````{{exec}}

This shows the controller quorum status and confirms KRaft mode is active.

````bash
exit
````{{exec}}

## Verify Cluster Topology

Get detailed information about the cluster:

````bash
kubectl describe kafka kafka -n confluent
````{{exec}}

Look for the `Status` section showing the cluster is ready.

A Single node kraft based kafka cluster is successfully deployed on kubernetes .
