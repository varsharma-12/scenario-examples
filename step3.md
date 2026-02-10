# Deploy Kafka Infrastructure

Before we can run our Kafka Streams applications, we need a Kafka cluster. Let's deploy Kafka and Zookeeper.

## Step 1: Deploy Kafka and Zookeeper

Deploy the Kafka infrastructure:

```bash
kubectl apply -f k8s/kafka.yaml
```{{exec}}

This creates:
- Zookeeper StatefulSet (needed for Kafka coordination)
- Kafka StatefulSet (the message broker)
- Services to expose Kafka and Zookeeper

## Step 2: Wait for Kafka to be Ready

Kafka takes about 60-90 seconds to start up. Let's wait for it:

```bash
kubectl wait --for=condition=ready pod -l app=kafka --timeout=300s
```{{exec}}

Watch the pods come up:

```bash
kubectl get pods -w
```{{exec}}

Press `Ctrl+C` once you see both `kafka-0` and `zookeeper-0` in "Running" status with "1/1" ready.

## Step 3: Verify Kafka is Working

Let's verify Kafka is functional by listing topics:

```bash
kubectl exec -it kafka-0 -- kafka-topics --list --bootstrap-server localhost:9092
```{{exec}}

The topic list should be empty (or show internal topics), which is fine.

## Step 4: Create the Required Topics

Our application needs two topics. Let's create them:

```bash
kubectl exec -it kafka-0 -- kafka-topics --create \
  --topic stock-trades \
  --partitions 3 \
  --replication-factor 1 \
  --bootstrap-server localhost:9092
```{{exec}}

```bash
kubectl exec -it kafka-0 -- kafka-topics --create \
  --topic processed-trades \
  --partitions 3 \
  --replication-factor 1 \
  --bootstrap-server localhost:9092
```{{exec}}

**Why these settings?**
- `stock-trades` - Input topic for raw trade messages
- `processed-trades` - Output topic for processed results
- 3 partitions - Allows parallel processing
- Replication factor 1 - Sufficient for demo (production would use 3)

## Step 5: Verify Topics

List topics again to confirm:

```bash
kubectl exec -it kafka-0 -- kafka-topics --list --bootstrap-server localhost:9092
```{{exec}}

You should see:
- `stock-trades`
- `processed-trades`

## Understanding the Kafka Setup

Check the Kafka configuration:

```bash
cat k8s/kafka.yaml | grep -A 5 "resources:"
```{{exec}}

Notice that Kafka is configured with:
- 2GB memory limit
- 2 CPU cores
- Persistent volume for data

This represents a typical containerized Kafka deployment.

## What's Next?

Kafka is ready! Now we can deploy our two Kafka Streams applications - one on JDK 21 and one on JDK 26 - to process messages from these topics.

Click **Continue** to deploy both applications.
