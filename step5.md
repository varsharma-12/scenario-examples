# Generate Realistic Load

Now let's send realistic stock trade messages to Kafka. Both applications will consume and process the same stream.

## Step 1: Get Kafka Service Endpoint

Find the Kafka service IP:

```bash
export KAFKA_ENDPOINT=$(kubectl get svc kafka -o jsonpath='{.spec.clusterIP}'):9092
echo "Kafka endpoint: $KAFKA_ENDPOINT"
```{{exec}}

## Step 2: Start the Load Generator

The load generator creates realistic stock trade messages. Start it at 1000 messages/second:

```bash
cd /root/demo/kafka-streams-demo
python3 scripts/load_generator.py $KAFKA_ENDPOINT 1000 &
```{{exec}}

**What this does:**
- Generates random stock trades (AAPL, GOOGL, MSFT, etc.)
- Includes ticker, price, volume, timestamp
- Publishes to `stock-trades` topic at 1000 msg/sec
- Runs in the background continuously

## Step 3: Verify Messages are Flowing

Check that messages are being published:

```bash
kubectl exec -it kafka-0 -- kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic stock-trades \
  --max-messages 5 \
  --from-beginning
```{{exec}}

You should see JSON messages like:
```json
{"ticker":"AAPL","price":178.45,"volume":1000,"timestamp":1234567890}
```

## Step 4: Verify Applications are Processing

Both applications should now be consuming and processing messages.

**Check JDK 21 is processing:**
```bash
kubectl logs -l version=jdk21 --tail=5
```{{exec}}

**Check JDK 26 is processing:**
```bash
kubectl logs -l version=jdk26 --tail=5
```{{exec}}

You should see log messages indicating messages are being processed.

## Step 5: Monitor Processing Rate

Both applications log their processing metrics every few seconds. Let's watch them:

```bash
kubectl logs -f -l version=jdk21 | grep "Messages Processed" &
kubectl logs -f -l version=jdk26 | grep "Messages Processed" &
```{{exec}}

Let this run for about 10-15 seconds to see several log entries, then press `Ctrl+C`.

**What to observe:**
- Messages processed per interval
- Average latency
- P99 latency
- GC pause notifications

## Understanding the Load Generator

Let's look at what the load generator does:

```bash
cat scripts/load_generator.py | head -50
```{{exec}}

The generator:
1. Creates random stock trades with realistic data
2. Serializes to JSON
3. Publishes to Kafka at specified rate
4. Uses round-robin across partitions for load balancing

## Current System State

At this point:
- ✅ Kafka is running and storing messages
- ✅ Load generator is producing 1000 msg/sec
- ✅ JDK 21 app is consuming and processing
- ✅ JDK 26 app is consuming and processing

Both applications are processing the **exact same messages** from Kafka, allowing for a fair comparison.

## What's Next?

Let the system warm up for a minute or two. Then we'll start monitoring the performance difference in real-time.

Click **Continue** to monitor live performance metrics.
