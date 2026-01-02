# Step 4: Verify KRaft Cluster

Let's thoroughly verify that our KRaft cluster is healthy and operational.

## Check Cluster Status

Verify all components are ready:
````bash
kubectl get kafkacontroller,kafka -n confluent
````{{exec}}

Both resources should show `READY` status with the correct replica count (3/3).

## Verify All Pods are Running

Check that all controller and broker pods are healthy:
````bash
kubectl get pods -n confluent -o wide
````{{exec}}

You should see 6 pods total:
- 3 `kafkacontroller-*` pods
- 3 `kafka-*` pods

All should be `Running` with `1/1` ready status.

## Check Controller Quorum Status

Verify the controller quorum is formed and healthy:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-metadata-quorum --bootstrap-server kafka:9092 describe --status
````{{exec}}

This output shows:
- **ClusterId**: Unique KRaft cluster identifier
- **LeaderId**: Current controller leader
- **Voters**: List of controller nodes in the quorum
- **Observers**: Broker nodes observing the quorum

## View Broker IDs

List all broker IDs in the cluster:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-broker-api-versions --bootstrap-server kafka:9092 | grep id
````{{exec}}

You should see three brokers (IDs 0, 1, 2).

## Check Cluster Metadata

View cluster metadata to confirm KRaft mode:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-metadata-quorum --bootstrap-server kafka:9092 describe --replication
````{{exec}}

This shows the metadata replication status across controllers.

## Verify Controller Endpoints

Check the controller service endpoints:
````bash
kubectl get endpoints kafkacontroller -n confluent
````{{exec}}

You should see 3 IP addresses (one for each controller pod).

## Verify Broker Endpoints

Check the broker service endpoints:
````bash
kubectl get endpoints kafka -n confluent
````{{exec}}

You should see 3 IP addresses (one for each broker pod).

## Check Pod Resources

View resource allocation for the pods:
````bash
kubectl top pods -n confluent
````{{exec}}

This shows CPU and memory usage for each pod.

## Describe Kafka Resource

Get detailed information about the Kafka broker cluster:
````bash
kubectl describe kafka kafka -n confluent
````{{exec}}

Look for the `Status` section showing:
- Phase: RUNNING
- Replicas: 3
- Ready Replicas: 3

## Describe KafkaController Resource

Get detailed information about the controller cluster:
````bash
kubectl describe kafkacontroller kafkacontroller -n confluent
````{{exec}}

## View Controller Logs

Check recent controller logs for any issues:
````bash
kubectl logs -n confluent kafkacontroller-0 --tail=30 | grep -i "error\|warn\|controller"
````{{exec}}

## View Broker Logs

Check recent broker logs:
````bash
kubectl logs -n confluent kafka-0 --tail=30 | grep -i "error\|warn\|started"
````{{exec}}

## Test Internal Connectivity

Verify brokers can communicate internally:
````bash
kubectl exec -n confluent kafka-0 -- \
  nc -zv kafka-1.kafka.confluent.svc.cluster.local 9092
````{{exec}}
````bash
kubectl exec -n confluent kafka-0 -- \
  nc -zv kafka-2.kafka.confluent.svc.cluster.local 9092
````{{exec}}

## Check Persistent Volumes

Verify persistent volumes are bound:
````bash
kubectl get pvc -n confluent
````{{exec}}

You should see 6 PVCs (3 for controllers, 3 for brokers), all in `Bound` status.

## Summary Check

Run a final comprehensive check:
````bash
echo "=== Cluster Summary ==="
echo "Controllers: $(kubectl get pods -n confluent -l app=kafkacontroller --no-headers | wc -l)/3"
echo "Brokers: $(kubectl get pods -n confluent -l app=kafka --no-headers | wc -l)/3"
echo "PVCs: $(kubectl get pvc -n confluent --no-headers | grep Bound | wc -l)/6"
echo ""
kubectl get kafkacontroller,kafka -n confluent
````{{exec}}

✅ **Verification Complete!** Your KRaft cluster is healthy and ready for use.

**Key Indicators of Health:**
- ✓ All 6 pods running (3 controllers + 3 brokers)
- ✓ Controller quorum established with a leader
- ✓ All brokers registered and operational
- ✓ Persistent volumes bound
- ✓ No critical errors in logs
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
