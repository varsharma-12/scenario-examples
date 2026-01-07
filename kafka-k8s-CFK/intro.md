# Deploy Kafka with KRaft on Kubernetes using Confluent Operator

Welcome! In this hands-on scenario, you'll learn how to deploy Apache Kafka using **KRaft mode** (Kafka Raft) on Kubernetes with the Confluent for Kubernetes (CFK) Operator.

This tutorial provides an handson experience to deploy kafka on kubernetes using enterprise grade operator i.e CFK.
The operator is a Kubernetes Deployment whose lifecycle is managed by Helm.
Kafka and Kraft will have their custom resource definitions (CRDs) deployed as kubernetes Statfulsets .
CFK actively monitors the custom resources to ensure their state matches the desired state.

CFK uses a declarative Kubernetes-native [API approach](https://docs.confluent.io/operator/current/co-api.html) to configure, deploy, and manage Apache Kafka and application resources (such as topics, rolebindings) through Infrastructure as Code (IaC).

## What is KRaft?

KRaft (Kafka Raft) is Kafka's new consensus protocol that **eliminates the dependency on ZooKeeper**. It simplifies operations, improves performance, and is the future of Kafka architecture.


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

