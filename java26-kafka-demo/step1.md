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

### Download and Extract Demo Files

```bash
mkdir -p /root/demo/kafka-streams-demo && \
wget [https://raw.githubusercontent.com/varsharma-12/scenario-examples/main/java26-kafka-demo/kafka-streams-demo.tar.gz](https://raw.githubusercontent.com/varsharma-12/scenario-examples/main/java26-kafka-demo/kafka-streams-demo.tar.gz) -O /root/kafka-streams-demo.tar.gz && \
tar -xzf /root/kafka-streams-demo.tar.gz -C /root/demo/kafka-streams-demo/
```{{exec}}

### Move to Workspace and Flatten Structure
Sometimes the tarball contains a nested folder. This command moves you into the folder and ensures the `pom.xml` is in the right place.

```bash
cd /root/demo/kafka-streams-demo/ && \
POM_PATH=$(find . -name pom.xml | head -n 1) && \
ACTUAL_DIR=$(dirname "$POM_PATH") && \
[ "$ACTUAL_DIR" != "." ] && mv "$ACTUAL_DIR"/* . || echo "Structure already flat"
```{{exec}}

### 3. Verify the Files
Confirm that `pom.xml` and `src` are visible.

```bash
ls -la
```{{exec}}


### 3. Build the Java Application
Run Maven to compile the code and create the executable JAR. We use `-DskipTests` to ensure the environment is ready quickly.

```bash
mvn clean package -DskipTests
```{{exec}}

### 4. Check Build Artifacts
Verify that the `target` directory now contains your compiled JAR file.

```bash
ls -l target/
```{{exec}}

---

### Troubleshooting
If the first `ls` command showed an empty directory, the background process is still copying files. Please wait 10 seconds and try again.

Now verify the demo files are extracted:

```bash
ls -la /root/demo/kafka-streams-demo/
```{{exec}}

You should see the application source code, Dockerfiles, and Kubernetes manifests.

Ready to build the application? Click **Continue** to proceed to the next step.
