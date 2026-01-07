## Step 5: Create and Manage Topics

Now let's create Kafka topics and learn how to manage them in a KRaft cluster.

## Create a Simple Topic

Create a topic with basic configuration:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --create \
  --topic demo-topic \
  --partitions 3 \
  --replication-factor 1
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
  --replication-factor 1 \
  --config retention.ms=86400000 \
  --config segment.bytes=104857600
````{{exec}}

Configuration :
- **retention.ms=86400000**: Keep messages for 24 hours
- **segment.bytes=104857600**: 100MB segment size

## List Topics with Details

View all topics with partition counts:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 --list
````{{exec}}

You should see:
- demo-topic
- orders-topic

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

## Verify Partition Increase

Check the updated partition count:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --describe \
  --topic orders-topic
````{{exec}}

## Check Topic Distribution Across Brokers

````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-topics --bootstrap-server kafka:9092 \
  --describe \
  --topic demo-topic | grep "Leader"
````{{exec}}

## Create Topic Using Declarative YAML

Confluent for Kubernetes (CFK) allows to declaratively create and manage Kafka topics as KafkaTopic custom resources (CRs) in Kubernetes. Each KafkaTopic CR is mapped to a topic and kept in sync with the corresponding Kafka topic.

````bash
cat <<EOF > kafka-topic.yaml
apiVersion: platform.confluent.io/v1beta1
kind: KafkaTopic
metadata:
  name: events-topic
  namespace: confluent
spec:
  replicas: 1
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

Confluent for Kubernetes (CFK) provides the custom resource definitions (CRDs) that were created using Kubernetes API
To vlaidate the settings that are supported in Confluent CRDs describe a specific CRD:

kubectl explain <CRD-type>.<fieldName>[.<fieldName>]

````bash
kubectl explain KafkaTopic.spec.partitionCount -n confluent
````{{exec}}

You've learned to:
- Create topics with various configurations
- Modify topic settings
- Scale partitions
- Use both imperative and declarative approaches
- Monitor topic distribution
```````````````````````````````````````````````````````````````````````````````````````
