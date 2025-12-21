# Step 3: Create Kafka Topics

Strimzi allows you to manage Kafka topics as Kubernetes resources.

## Create a Topic Using kubectl

Create a topic definition:
````````````````````````````````````````````````````````````````````````````bash
cat < my-topic.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: demo-topic
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 2
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF
```````````````````````````````````````````````````````````````````````````{{exec}}

Apply the topic:
``````````````````````````````````````````````````````````````````````````bash
kubectl apply -f my-topic.yaml
`````````````````````````````````````````````````````````````````````````{{exec}}

## Verify Topic Creation

List Kafka topics:
````````````````````````````````````````````````````````````````````````bash
kubectl get kafkatopics -n kafka
```````````````````````````````````````````````````````````````````````{{exec}}

Get topic details:
``````````````````````````````````````````````````````````````````````bash
kubectl describe kafkatopic demo-topic -n kafka
`````````````````````````````````````````````````````````````````````{{exec}}

## Create Topics Using Kafka Tools

You can also use native Kafka tools. First, exec into a Kafka pod:
````````````````````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --list
```````````````````````````````````````````````````````````````````{{exec}}

Create a topic using kafka-topics.sh:
``````````````````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --create \
  --topic manual-topic \
  --partitions 3 \
  --replication-factor 2
`````````````````````````````````````````````````````````````````{{exec}}

**Note**: Topics created manually won't be managed by the Topic Operator.

## Describe Topic Details
````````````````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --describe \
  --topic demo-topic
```````````````````````````````````````````````````````````````{{exec}}

You'll see partition assignments across brokers.

## Modify Topic Configuration

Update the topic retention:
``````````````````````````````````````````````````````````````bash
kubectl patch kafkatopic demo-topic -n kafka --type merge \
  -p '{"spec":{"config":{"retention.ms":"7200000"}}}'
`````````````````````````````````````````````````````````````{{exec}}

Verify the change:
````````````````````````````````````````````````````````````bash
kubectl get kafkatopic demo-topic -n kafka -o yaml
```````````````````````````````````````````````````````````{{exec}}

✅ **Checkpoint**: Topics created and managed via Kubernetes!
```````````````````````````````````````````````````````````

---

