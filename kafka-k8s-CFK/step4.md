# Step 4: Verify KRaft Cluster

Let's thoroughly verify that our KRaft cluster is healthy and operational.

## Check Cluster Status

Verify all components are ready:
````bash
kubectl get kraftcontroller,kafka -n confluent
````{{exec}}

Both resources should show `READY` status with correct replica count .

## Verify All Pods are Running

Check that all controller and broker pods are healthy:
````bash
kubectl get pods -n confluent -o wide
````{{exec}}

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

## View Broker ID

List all broker ID in the cluster:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-broker-api-versions --bootstrap-server kafka:9092 | grep id
````{{exec}}

## Check Cluster Metadata

View cluster metadata to confirm KRaft mode:
````bash
kubectl exec -n confluent kafka-0 -- \
  kafka-metadata-quorum --bootstrap-server kafka:9092 describe --replication
````{{exec}}

This shows the metadata replication status across controller.

## Verify Controller Endpoints

Check the controller service endpoints:
````bash
kubectl get endpoints kafkacontroller -n confluent
````{{exec}}


## Verify Broker Endpoints

Check the broker service endpoints:
````bash
kubectl get endpoints kafka -n confluent
````{{exec}}

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


## Check Persistent Volumes

Verify persistent volumes are bound:
````bash
kubectl get pvc -n confluent
````{{exec}}
