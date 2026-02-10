# Understanding the Garbage Collection Challenge

Before we dive into the demo, let's understand what we're trying to solve.

## The Stop-The-World Problem

Java applications automatically manage memory through Garbage Collection (GC). But during GC, the application must pause completely - these are **Stop-The-World (STW)** pauses.

### Impact on Data Streaming Applications

For applications processing thousands of messages per second (like Kafka Streams, Flink, or real-time analytics):

**A 20ms GC pause means:**
- 20 messages delayed (at 1000 msg/sec)
- Potential timeout for time-sensitive operations
- Risk of Kubernetes thinking the pod is unhealthy
- Consumer lag building up

**A 50ms GC pause can cause:**
- Readiness probe failures → pod restart
- Consumer rebalance → entire consumer group pauses
- Missed SLA targets for P99 latency
- Cascading failures in microservices

## Our Demo Application

We'll use a Kafka Streams application that processes stock trades:

```
Stock Trade → [Parse JSON] → [Calculate Volatility] → [Aggregate] → Output
```

**Why this stresses GC:**
- Creates 100+ temporary objects per message
- Performs 1000+ iterations for volatility calculations
- Maintains stateful windowed aggregations in memory
- String concatenation creates garbage

This simulates real-world scenarios:
- Financial transaction processing
- IoT sensor data aggregation  
- Real-time analytics pipelines
- Event correlation systems

## What Java 26 Improves

The G1 Garbage Collector in Java 26 includes:

1. **Concurrent Refinement** - More work in background, less STW time
2. **Adaptive Regions** - Smarter heap management for workload patterns
3. **Better Evacuation** - Improved algorithms for memory compaction
4. **Container Optimization** - Aware of Kubernetes CPU/memory limits

**The best part:** Zero code changes needed!

## Let's Verify the Setup

First, let's check that our Kubernetes cluster is ready:

```bash
kubectl get nodes
```{{exec}}

You should see 2 nodes in "Ready" status.

Now verify the demo files are extracted:

```bash
ls -la /root/demo/kafka-streams-demo/
```{{exec}}

You should see the application source code, Dockerfiles, and Kubernetes manifests.

Ready to build the application? Click **Continue** to proceed to the next step.
