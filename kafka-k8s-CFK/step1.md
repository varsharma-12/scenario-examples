# Step 1: Verify Kubernetes Cluster

Before deploying Kafka with KRaft, let's verify that your Kubernetes cluster is running properly.

## Check Cluster Status

Run the following command to check the nodes:

````bash
kubectl get nodes
````{{exec}}

You should see the nodes in a `Ready` state.

## Create Confluent Namespace

Create a dedicated namespace for Confluent Platform components:

````bash
kubectl create namespace confluent
````{{exec}}

Set this namespace as the default for subsequent commands:

````bash
kubectl config set-context --current --namespace=confluent
````{{exec}}

## Verify Namespace

Confirm the namespace was created:

````bash
kubectl get namespaces | grep confluent
````{{exec}}

## Check Available Storage

Verify that your cluster has storage provisioners available:

````bash
kubectl get storageclass
````{{exec}}

Perfect! Your cluster is ready for Kafka KRaft deployment.
