# Step 2: Deploy Kafka Cluster (KRaft Mode)

Now let's deploy a Kafka cluster with 3 brokers using KRaft mode .

## What is KRaft?

KRaft (Kafka Raft) is Kafka's new consensus protocol that eliminates the dependency on ZooKeeper. Benefits include:
- Simpler architecture (fewer moving parts)
- Faster metadata operations
- Improved scalability
- ZooKeeper will be removed in Kafka 4.0

## Create kafka-with-dual-role Cluster

Create a new Kafka custom resource .

````bash
cat <<EOF > KafkaNodePool.yaml
apiVersion: kafka.strimzi.io/v1
kind: KafkaNodePool
metadata:
  name: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  replicas: 3
  roles:
    - controller
    - broker
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: 100Gi
        deleteClaim: false
        kraftMetadata: shared
EOF
````{{exec}}

Apply the configuration:

````bash
kubectl apply -f KafkaNodePool.yaml -n kafka
````{{exec}}

Create a new Kafka custom resource .

````bash
cat <<EOF > kafka.yaml
apiVersion: kafka.strimzi.io/v1
kind: Kafka
metadata:
  name: my-cluster
  annotations:
    strimzi.io/node-pools: enabled  
    strimzi.io/kraft: enabled
spec:
  kafka:
    version: 4.1.1
    metadataVersion: 4.1-IV1
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
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF
````{{exec}}

Apply the configuration:
````bash
kubectl apply -f kafka.yaml -n kafka
````{{exec}}


## Understanding the Configuration

Let's break down what we just created:

**KRaft-Specific Changes:**
- **No zookeeper section** - KRaft mode doesn't need ZooKeeper!
- **strimzi.io/kraft: enabled** - Enables KRaft mode
- **kafka.replicas: 3** - Brokers also act as controllers in KRaft

**Other Settings:**
- **listeners** - Two listeners (plain and TLS)
- **config** - Production-ready Kafka settings
- **storage: ephemeral** - Using emptyDir (for demo; use persistent-claim in production)
- **entityOperator** - Manages topics and users

## Watch Deployment

Watch the pods being created:
````bash
kubectl get pods -n kafka -w
````{{exec}}

This will take 1-2 minutes . You should see:
- 3 Kafka broker pods: `my-cluster-kafka-0/1/2` (these are also controllers)
- Entity operator pod: `my-cluster-entity-operator-*`

Press `Ctrl+C` once all pods are `Running`.

## Verify Kafka Cluster

Check the Kafka resource status:
````bash
kubectl get kafka -n kafka
````{{exec}}

You should see `DESIRED KAFKA REPLICAS: 3` and `READY: True`.

Get detailed information:
````bash
kubectl describe kafka my-cluster -n kafka
````{{exec}}

Look for the KRaft annotation :

Check cluster services:
````bash
kubectl get svc -n kafka
````{{exec}}

You should see:
- `my-cluster-kafka-bootstrap` (for clients to connect)
- `my-cluster-kafka-brokers` (headless service)
- **No zookeeper services** - KRaft doesn't need them!

## Verify KRaft Mode

Check that brokers are running in KRaft mode:
````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- cat /tmp/strimzi.properties | grep process.roles
````{{exec}}

You should see `process.roles=broker,controller` - this means the broker is also acting as a controller.

List the controller quorum:
````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-metadata-quorum.sh --bootstrap-server localhost:9092 describe --status
````{{exec}}

This shows the KRaft controller status and leader information.

## Test Connectivity

Get the bootstrap service endpoint:
````bash
kubectl get svc my-cluster-kafka-bootstrap -n kafka
````{{exec}}

Test creating a topic using the Kafka CLI:
````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list
````{{exec}}

## Compare: KRaft vs ZooKeeper

✅ **Checkpoint**: Your 3-node KRaft-based Kafka cluster is now running!
`````````

---

Some KRaft verification steps:

Check the metadata log directory:
````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- ls -la /var/lib/kafka/data/kraft-combined-logs
````{{exec}}

View KRaft metadata:
````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-metadata-shell.sh --snapshot /var/lib/kafka/data/__cluster_metadata-0/00000000000000000000.log
````{{exec}}

Check cluster metadata version:
````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-features.sh --bootstrap-server localhost:9092 describe
```{{exec}}
