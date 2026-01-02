## Step 6: Produce and Consume Messages

# Step 6: Produce and Consume Messages

Let's test our Kafka cluster by producing and consuming messages.

## Produce Messages to demo-topic

Start producing messages interactively:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-console-producer --bootstrap-server kafka:9092 \
  --topic demo-topic
````{{exec}}

**Type messages and press Enter after each one:**
`````````````````````````````````````````````````````````````````````````````````````
Hello Kafka with KRaft!
This is message number 2
Testing message production
``````````````````````````````````````````````````````````````````````````````````````

Press `Ctrl+C` to stop producing.

## Produce Messages with Keys

Produce messages with keys for proper partitioning:
````bash
kubectl exec -n confluent kafka-0 -- bash -c '
echo "user1:Login successful" | kafka-console-producer \
  --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --property "parse.key=true" \
  --property "key.separator=:"
'
````{{exec}}
````bash
kubectl exec -n confluent kafka-0 -- bash -c '
echo "user2:Order placed" | kafka-console-producer \
  --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --property "parse.key=true" \
  --property "key.separator=:"
'
````{{exec}}
````bash
kubectl exec -n confluent kafka-0 -- bash -c '
echo "user1:Logout successful" | kafka-console-producer \
  --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --property "parse.key=true" \
  --property "key.separator=:"
'
````{{exec}}
## Consume Messages from Beginning

Read all messages from the topic:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-console-consumer --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --from-beginning \
  --timeout-ms 10000
````{{exec}}
This will display all messages and exit after 10 seconds.

## Consume Messages with Keys and Timestamps

View messages with metadata:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-console-consumer --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --from-beginning \
  --property print.key=true \
  --property print.timestamp=true \
  --property key.separator=" | " \
  --timeout-ms 10000
````{{exec}}

Output format: `timestamp | key | value`

## Produce Batch Messages

Send multiple messages at once:
````bash
kubectl exec -n c
onfluent kafka-0 -- bash -c '
echo -e "order1:Product A ordered\norder2:Product B ordered\norder3:Product C ordered" | \
kafka-console-producer \
  --bootstrap-server kafka:9092 \
  --topic orders-topic \
  --property "parse.key=true" \
  --property "key.separator=:"
'
````{{exec}}

## Consume from Specific Partition

Read from partition 0 only:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-console-consumer --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --partition 0 \
  --from-beginning \
  --timeout-ms 10000
````{{exec}}

## Create Consumer Group

Consume with a consumer group for offset tracking:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-console-consumer --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --group demo-consumer-group \
  --from-beginning \
  --timeout-ms 10000
````{{exec}}

## Check Consumer Group Status

View consumer group information:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-consumer-groups --bootstrap-server kafka:9092 \
  --describe \
  --group demo-consumer-group
````{{exec}}

This shows:
- Current offset per partition
- Log end offset
- Lag (messages behind)
- Consumer ID

## List All Consumer Groups

View all consumer groups:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-consumer-groups --bootstrap-server kafka:9092 --list
````{{exec}}

## Produce JSON Messages

Send structured JSON data:
````bash
kubectl exec -n confluent kafka-0 -- bash -c '
echo '\''{"user_id": "user123", "action": "login", "timestamp": "2025-01-02T10:30:00Z"}'\'' | \
kafka-console-producer \
  --bootstrap-server kafka:9092 \
  --topic orders-topic
'
````{{exec}}
````bash
kubectl exec -n confluent kafka-0 -- bash -c '
echo '\''{"user_id": "user456", "action": "purchase", "amount": 99.99}'\'' | \
kafka-console-producer \
  --bootstrap-server kafka:9092 \
  --topic orders-topic
'
````{{exec}}

## Consume and Format JSON

Consume JSON messages:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-console-consumer --bootstrap-server kafka:9092 \
  --topic orders-topic \
  --from-beginning \
  --timeout-ms 10000
````{{exec}}

## Test Message Throughput

Produce 1000 messages for performance testing:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-producer-perf-test \
  --topic demo-topic \
  --num-records 1000 \
  --record-size 100 \
  --throughput 100 \
  --producer-props bootstrap.servers=kafka:9092
````{{exec}}

## Consume with Performance Testing

Test consumer throughput:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-consumer-perf-test \
  --bootstrap-server kafka:9092 \
  --topic demo-topic \
  --messages 1000 \
  --timeout 10000
````{{exec}}

## Check Topic Message Count

Get the total number of messages per partition:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-run-class kafka.tools.GetOffsetShell \
  --broker-list kafka:9092 \
  --topic demo-topic
````{{exec}}

## Reset Consumer Group Offset

Reset offset to beginning (use with caution):
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-consumer-groups --bootstrap-server kafka:9092 \
  --group demo-consumer-group \
  --topic demo-topic \
  --reset-offsets \
  --to-earliest \
  --execute
````{{exec}}

## Verify Offset Reset

Check the updated offsets:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-consumer-groups --bootstrap-server kafka:9092 \
  --describe \
  --group demo-consumer-group
````{{exec}}


✅ **Message Production and Consumption Complete!** You've learned to:
- Produce and consume messages
- Use keys for partitioning
- Work with consumer groups
- Test performance
- Manage offsets
```````````````````````````````````````````````
