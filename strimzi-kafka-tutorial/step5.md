### **step5.md** (Scale and Monitor)
`````````````````````````````````````````````````markdown
# Step 5: Scale and Monitor Kafka

Learn how to scale your Kafka cluster and monitor its health.

## Scale Kafka Brokers

Currently, we have 3 brokers. Let's scale to 5:
````````````````````````````````````````````````bash
kubectl patch kafka my-cluster -n kafka --type merge \
  -p '{"spec":{"kafka":{"replicas":5}}}'
```````````````````````````````````````````````{{exec}}

Watch the new pods being created:
``````````````````````````````````````````````bash
kubectl get pods -n kafka -w
`````````````````````````````````````````````{{exec}}

Press `Ctrl+C` once you see 5 Kafka pods running.

## Verify Scaling

Check broker IDs:
````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-broker-api-versions.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092
```````````````````````````````````````````{{exec}}

You should see 5 broker IDs (0-4).

## Monitor Cluster Health

Check pod resource usage:
``````````````````````````````````````````bash
kubectl top pods -n kafka
`````````````````````````````````````````{{exec}}

View broker logs:
````````````````````````````````````````bash
kubectl logs my-cluster-kafka-0 -n kafka --tail=50
```````````````````````````````````````{{exec}}

## Partition Reassignment

Create a topic to demonstrate rebalancing:
``````````````````````````````````````bash
cat <<EOF | kubectl apply -f -
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: test-rebalance
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 10
  replicas: 2
EOF
`````````````````````````````````````{{exec}}

Check partition distribution:
````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --describe \
  --topic test-rebalance
```````````````````````````````````{{exec}}

Notice partitions might not be evenly distributed. In production, you'd use Cruise Control for auto-rebalancing.

## Rolling Update

Trigger a rolling restart (useful after configuration changes):
``````````````````````````````````bash
kubectl annotate kafka my-cluster -n kafka \
  strimzi.io/manual-rolling-update=true
`````````````````````````````````{{exec}}

Watch the rolling restart:
````````````````````````````````bash
kubectl get pods -n kafka -w
```````````````````````````````{{exec}}

Pods will restart one at a time. Press `Ctrl+C` when complete.

## Check Cluster Status

Get Kafka resource status:
``````````````````````````````bash
kubectl get kafka my-cluster -n kafka -o jsonpath='{.status.conditions[*].type}' | tr ' ' '\n'
`````````````````````````````{{exec}}

Should show: `Ready`

## Scale Down

Scale back to 3 brokers:
````````````````````````````bash
kubectl patch kafka my-cluster -n kafka --type merge \
  -p '{"spec":{"kafka":{"replicas":3}}}'
```````````````````````````{{exec}}

**Warning**: In production, ensure partitions are reassigned before scaling down!

✅ **Checkpoint**: Scaled and monitored Kafka cluster successfully!
```````````````````````````

---

