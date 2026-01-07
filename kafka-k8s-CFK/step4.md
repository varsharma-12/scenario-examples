# Step 4: Verify Cluster

Here are some commands to debug the deployed clsuter.

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

## Describe Kafka Resource

Get detailed information about the Kafka broker cluster:
````bash
kubectl describe kafka kafka -n confluent
````{{exec}}

## Describe kraftcontroller Resource

Get detailed information about the controller cluster:
````bash
kubectl describe kraftcontroller kraftcontroller -n confluent
````{{exec}}

## View Controller Logs

Check recent controller logs for any issues:
````bash
kubectl logs -n confluent kraftcontroller-0 --tail=30 
````{{exec}}

## View Broker Logs

Check recent broker logs:
````bash
kubectl logs -n confluent kafka-0 --tail=30
````{{exec}}

## Check Persistent Volumes

Verify persistent volumes are bound:
````bash
kubectl get pv,pvc -n confluent
````{{exec}}
