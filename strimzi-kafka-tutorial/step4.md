# Step 4: Produce and Consume Messages

Let's test message production and consumption.

## Run Console Producer

Open a producer in one terminal:
``````````````````````````````````````````````````````````bash
kubectl run kafka-producer -ti \
  --image=quay.io/strimzi/kafka:latest-kafka-3.6.0 \
  --rm=true --restart=Never -n kafka -- \
  bin/kafka-console-producer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic demo-topic
`````````````````````````````````````````````````````````{{exec}}

Type some messages and press Enter after each:
`````````````````````````````````````````````````````````
Hello Kafka!
This is message 2
Testing Strimzi
``````````````````````````````````````````````````````````

Keep this terminal open for now.

## Run Console Consumer (New Terminal Tab)

Click the `+` icon to open a new terminal tab, then run:
``````````````````````````````````````````````````````````bash
kubectl run kafka-consumer -ti \
  --image=quay.io/strimzi/kafka:latest-kafka-3.6.0 \
  --rm=true --restart=Never -n kafka -- \
  bin/kafka-console-consumer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic demo-topic \
  --from-beginning
`````````````````````````````````````````````````````````{{exec}}

You should see all messages appear!

## Test with Consumer Groups

Exit the consumer (Ctrl+C) and start a new one with a group:
````````````````````````````````````````````````````````bash
kubectl run kafka-consumer-group -ti \
  --image=quay.io/strimzi/kafka:latest-kafka-3.6.0 \
  --rm=true --restart=Never -n kafka -- \
  bin/kafka-console-consumer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic demo-topic \
  --group my-consumer-group \
  --from-beginning
```````````````````````````````````````````````````````{{exec}}

## Check Consumer Group Status

In another terminal:
``````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-consumer-groups.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --describe \
  --group my-consumer-group
`````````````````````````````````````````````````````{{exec}}

You'll see lag, current offset, and partition assignments.

## Performance Test

Let's do a quick performance test. Producer test:
````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-producer-perf-test.sh \
  --topic demo-topic \
  --num-records 10000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props bootstrap.servers=my-cluster-kafka-bootstrap:9092
```````````````````````````````````````````````````{{exec}}

Consumer test:
``````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-consumer-perf-test.sh \
  --topic demo-topic \
  --messages 10000 \
  --bootstrap-server my-cluster-kafka-bootstrap:9092
`````````````````````````````````````````````````{{exec}}

✅ **Checkpoint**: Successfully produced and consumed messages!
`````````````````````````````````````````````````

---

