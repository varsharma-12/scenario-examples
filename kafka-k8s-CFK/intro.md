# Deploy Kafka with KRaft on Kubernetes using Confluent Operator

Welcome! In this hands-on scenario, you'll learn how to deploy Apache Kafka using **KRaft mode** (Kafka Raft) on Kubernetes with the Confluent for Kubernetes (CFK) Operator.

## What is KRaft?

KRaft (Kafka Raft) is Kafka's new consensus protocol that **eliminates the dependency on ZooKeeper**. It simplifies operations, improves performance, and is the future of Kafka architecture.


## What You'll Learn

- Install and configure the Confluent for Kubernetes Operator
- Deploy a production-ready Kafka cluster in KRaft mode
- Understand KRaft controller and broker roles
- Create and manage Kafka topics
- Produce and consume messages
- Scale your KRaft cluster

## Prerequisites

- Basic understanding of Kubernetes concepts
- Familiarity with Apache Kafka terminology
- Command-line experience

## Architecture

You'll deploy:
- **Confluent Operator**: Manages Kafka infrastructure
- **Kafka Controllers**: Handle metadata consensus (3 replicas)
- **Kafka Brokers**: Message streaming platform (3 replicas)

