
# Step 2: Deploy Kafka Cluster

Now let's deploy a Kafka cluster with 3 brokers and 3 ZooKeeper nodes.

## Create Kafka Cluster

Create a file with the Kafka cluster definition:
``````````````````````````````````````````````````````````````````````````````````````````bash
cat < kafka-cluster.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
  namespace: kafka
spec:
  kafka:
    version: 3.6.0
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      default.replication.factor: 3
      min.insync.replicas: 2
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF
`````````````````````````````````````````````````````````````````````````````````````````{{exec}}

Apply the configuration:
````````````````````````````````````````````````````````````````````````````````````````bash
kubectl apply -f kafka-cluster.yaml
```````````````````````````````````````````````````````````````````````````````````````{{exec}}

## Understanding the Configuration

Let's break down what we just created:

- **kafka.replicas: 3** - Three Kafka broker pods
- **listeners** - Two listeners (plain and TLS)
- **config** - Production-ready Kafka settings
- **storage: ephemeral** - Using emptyDir (for demo; use persistent-claim in production)
- **zookeeper.replicas: 3** - Three ZooKeeper nodes
- **entityOperator** - Manages topics and users

## Watch Deployment

Watch the pods being created:
``````````````````````````````````````````````````````````````````````````````````````bash
kubectl get pods -n kafka -w
`````````````````````````````````````````````````````````````````````````````````````{{exec}}

This will take 2-3 minutes. You should see:
- 3 ZooKeeper pods: `my-cluster-zookeeper-0/1/2`
- 3 Kafka broker pods: `my-cluster-kafka-0/1/2`
- Entity operator pod: `my-cluster-entity-operator-*`

Press `Ctrl+C` once all pods are `Running`.

## Verify Kafka Cluster

Check the Kafka resource status:
````````````````````````````````````````````````````````````````````````````````````bash
kubectl get kafka -n kafka
```````````````````````````````````````````````````````````````````````````````````{{exec}}

Get detailed information:
``````````````````````````````````````````````````````````````````````````````````bash
kubectl describe kafka my-cluster -n kafka
`````````````````````````````````````````````````````````````````````````````````{{exec}}

Check cluster services:
````````````````````````````````````````````````````````````````````````````````bash
kubectl get svc -n kafka
```````````````````````````````````````````````````````````````````````````````{{exec}}

You should see:
- `my-cluster-kafka-bootstrap` (for clients to connect)
- `my-cluster-kafka-brokers` (headless service)
- `my-cluster-zookeeper-nodes`

## Test Connectivity

Get the bootstrap service endpoint:
``````````````````````````````````````````````````````````````````````````````bash
kubectl get svc my-cluster-kafka-bootstrap -n kafka
`````````````````````````````````````````````````````````````````````````````{{exec}}

✅ **Checkpoint**: Your 3-node Kafka cluster is now running!
`````````````````````````````````````````````````````````````````````````````

---

