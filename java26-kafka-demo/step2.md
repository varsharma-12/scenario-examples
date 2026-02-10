# Build the Application

Now let's build the Kafka Streams application and create Docker images for both JDK versions.

## Step 1: Build the Java Application

Navigate to the demo directory and build with Maven:

```bash
cd /root/demo/kafka-streams-demo
mvn clean package -DskipTests
```{{exec}}

This compiles the `StockTradeProcessor` application and creates a JAR file. The build should take about 30-60 seconds.

**What's in this application?**
- Kafka Streams topology for processing trades
- Memory-intensive volatility calculations
- Stateful windowed aggregations
- Prometheus metrics for monitoring

## Step 2: Build Docker Image for JDK 21

Let's create the baseline Docker image using JDK 21:

```bash
docker build -f Dockerfile.jdk21 -t stock-processor:jdk21 .
```{{exec}}

**What's happening:**
- Starts from `eclipse-temurin:21-jre` base image
- Copies the application JAR
- Configures JVM with 2GB heap and G1GC
- Exposes port 8080 for metrics

## Step 3: Build Docker Image for JDK 26

Now build the improved version with JDK 26:

```bash
docker build -f Dockerfile.jdk26 -t stock-processor:jdk26 .
```{{exec}}

**Important:** This uses the exact same application code! The only difference is the JDK version.

## Step 4: Verify the Images

Check that both images were created successfully:

```bash
docker images | grep stock-processor
```{{exec}}

You should see two images:
- `stock-processor:jdk21`
- `stock-processor:jdk26`

## Understanding the Dockerfile

Let's look at what's in the JDK 21 Dockerfile:

```bash
cat Dockerfile.jdk21
```{{exec}}

Notice the JVM options:
- `-Xmx2g -Xms2g` - 2GB heap (fixed size)
- `-XX:+UseG1GC` - Use G1 Garbage Collector
- `-XX:MaxGCPauseMillis=200` - Target max 200ms pauses
- `-XX:+PrintGCDetails` - Log GC activity

The JDK 26 Dockerfile is identical except for the base image version.

## What's Next?

Now that we have both images built, we're ready to deploy to Kubernetes. We'll start with Kafka infrastructure, then deploy both versions of our application side-by-side.

Click **Continue** to deploy Kafka.
