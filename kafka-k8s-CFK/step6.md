## Step 6: Produce and Consume Messages

Let's test Kafka cluster by producing and consuming messages.

## Produce Messages to demo-topic

Start producing messages interactively:
````bash
kubectl -n confluent exec -it kafka-0 -- bash
````{{exec}}

````bash
seq 5 | kafka-console-producer --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
  --topic demo-topic
````{{exec}}

## Consume Messages from Beginning

Read all messages from the topic:

````bash
kafka-console-consumer --bootstrap-server kafka:9071 \
  --topic demo-topic \
  --from-beginning \
  --timeout-ms 10000
````{{exec}}
This will display all messages and exit after 10 seconds.


```````````````````````````````````````````````
