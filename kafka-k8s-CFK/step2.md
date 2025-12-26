# Step 2: Install Confluent for Kubernetes Operator

The Confluent for Kubernetes (CFK) Operator manages Kafka deployments, including KRaft mode configurations.

## Add Confluent Helm Repository

First, add the Confluent Helm repository:

````bash
helm repo add confluentinc https://packages.confluent.io/helm
````{{exec}}

Update the repository to get the latest charts:

````bash
helm repo update
````{{exec}}

## Install CFK Operator

Install the Confluent for Kubernetes Operator using Helm:

````bash
helm upgrade --install confluent-operator \
  confluentinc/confluent-for-kubernetes \
  --namespace confluent \
  --set kRaftEnabled=true
````{{exec}}

**Note:** The `--set kRaftEnabled=true` flag ensures KRaft support is enabled.

This will take 1-2 minutes to complete.

## Verify Operator Installation

Check that the operator pod is running:

````bash
kubectl get pods -n confluent
````{{exec}}

Wait until the pod shows `STATUS` as `Running`. You can watch the status with:

````bash
kubectl get pods -n confluent -w
````{{exec}}

Press `Ctrl+C` to stop watching once the pod is running.

## Check Operator Logs

View the operator logs to ensure it started correctly:

````bash
kubectl logs -l app=confluent-operator -n confluent --tail=50
````{{exec}}

## Verify CRDs

Check that the Kafka Custom Resource Definition is installed:

````bash
kubectl get crd kafkas.platform.confluent.io
````{{exec}}

Great! The operator is ready to deploy Kafka in KRaft mode.
