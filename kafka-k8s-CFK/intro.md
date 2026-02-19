# Deploy Kafka with KRaft on Kubernetes using Confluent Operator

Welcome! In this hands-on scenario, you'll learn how to deploy Apache Kafka using **KRaft mode** (Kafka Raft) on Kubernetes with the Confluent for Kubernetes (CFK) Operator.

This tutorial provides a handson experience to deploy kafka on kubernetes using enterprise grade operator i.e CFK.
The operator is a Kubernetes Deployment whose lifecycle is managed by Helm.
Kafka and Kraft will have their custom resource definitions (CRDs) deployed as kubernetes Statfulsets .
CFK actively monitors the custom resources to ensure their state matches the desired state.

CFK uses a declarative Kubernetes-native [API approach](https://docs.confluent.io/operator/current/co-api.html) to configure, deploy, and manage Apache Kafka and application resources (such as topics, rolebindings) through Infrastructure as Code (IaC).

## What is KRaft?

KRaft (Kafka Raft) is Kafka's new consensus protocol that **eliminates the dependency on ZooKeeper**. It greatly simplifies Kafka’s architecture by consolidating responsibility for metadata into Kafka itself.

The following image provides a simple illustration of Kafka running with KRaft managing metadata for the cluster. Each KRaft controller is a node in a Raft quorum, and each node is a broker that can handle client requests.

<img width="537" height="687" alt="image" src="https://github.com/user-attachments/assets/9736ac5a-0411-4326-aa73-879a360977ac" />

## What You'll Learn

- Install and configure the Confluent for Kubernetes Operator
- Deploy a  Kafka cluster in KRaft mode
- Understand KRaft controller and broker roles
- Create and manage Kafka topics
- Produce and consume messages

## Prerequisites

- Basic understanding of Kubernetes concepts
- Familiarity with Apache Kafka terminology
- Command-line experience

