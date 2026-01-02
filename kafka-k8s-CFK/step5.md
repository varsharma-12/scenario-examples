## Step 5: Create and Manage Topics

# Step 5: Create and Manage Topics

Now let's create Kafka topics and learn how to manage them in a KRaft cluster.

## Create a Simple Topic

Create a topic with basic configuration:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --create \
  --topic demo-topic \
  --partitions 3 \
  --replication-factor 3
````{{exec}}

This creates a topic with:
- **3 partitions**: For parallel processing
- **Replication factor 3**: Each partition replicated across all brokers

## List All Topics

View all topics in the cluster:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 --list
````{{exec}}

## Describe the Topic

Get detailed information about the topic:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --describe \
  --topic demo-topic
````{{exec}}

This shows:
- Partition distribution across brokers
- Leader broker for each partition
- In-sync replicas (ISR)

## Create a Topic with Custom Configuration

Create a topic with custom retention and segment settings:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --create \
  --topic orders-topic \
  --partitions 6 \
  --replication-factor 3 \
  --config retention.ms=86400000 \
  --config segment.bytes=104857600
````{{exec}}

Configuration explained:
- **retention.ms=86400000**: Keep messages for 24 hours
- **segment.bytes=104857600**: 100MB segment size

## Create a Compacted Topic

Create a log-compacted topic for storing latest state:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --create \
  --topic user-state \
  --partitions 3 \
  --replication-factor 3 \
  --config cleanup.policy=compact \
  --config min.compaction.lag.ms=60000
````{{exec}}

Compacted topics retain only the latest value per key.

## List Topics with Details

View all topics with partition counts:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 --list
````{{exec}}

You should see:
- demo-topic
- orders-topic
- user-state

## Describe All Topics

Get details for all topics:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 --describe
````{{exec}}

## Modify Topic Configuration

Update the retention policy for demo-topic:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-configs --bootstrap-server kafka:9092 \
  --entity-type topics \
  --entity-name demo-topic \
  --alter \
  --add-config retention.ms=172800000
````{{exec}}

This changes retention to 48 hours (172800000 ms).

## View Topic Configuration

Check the updated configuration:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-configs --bootstrap-server kafka:9092 \
  --entity-type topics \
  --entity-name demo-topic \
  --describe
````{{exec}}

## Increase Topic Partitions

Add more partitions to orders-topic:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --alter \
  --topic orders-topic \
  --partitions 9
````{{exec}}

**Note**: You can only increase partitions, not decrease them.

## Verify Partition Increase

Check the updated partition count:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --describe \
  --topic orders-topic
````{{exec}}

## Check Topic Distribution Across Brokers

See how partitions are distributed:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --describe \
  --topic demo-topic | grep "Leader"
````{{exec}}

Each broker should be leading approximately equal numbers of partitions.

## Create Topic Using Declarative YAML (Alternative Method)

You can also create topics using Kubernetes custom resources:
````bash
cat <<EOF > kafka-topic.yaml
apiVersion: platform.confluent.io/v1beta1
kind: KafkaTopic
metadata:
  name: events-topic
  namespace: confluent
spec:
  replicas: 3
  partitionCount: 6
  configs:
    retention.ms: "259200000"
    segment.bytes: "104857600"
  kafkaClusterRef:
    name: kafka
EOF
````{{exec}}

Apply the topic resource:
````bash
kubectl apply -f kafka-topic.yaml
````{{exec}}

## Verify Declarative Topic

Check the topic was created:
````bash
kubectl get kafkatopic -n confluent
````{{exec}}
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --describe \
  --topic events-topic
````{{exec}}

## View All Topics Summary

Get a summary of all topics:
````bash
echo "=== Topics Summary ==="
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 --list | \
  while read topic; do
    echo "Topic: $topic"
    kubectl exec -n confluent kafka-0 -- \
      kafka-topics --bootstrap-server kafka:9092 \
      --describe --topic $topic | grep "PartitionCount"
  done
````{{exec}}

✅ **Topic Management Complete!** You've learned to:
- Create topics with various configurations
- Modify topic settings
- Scale partitions
- Use both imperative and declarative approaches
- Monitor topic distribution
```````````````````````````````````````````````````````````````````````````````````````
