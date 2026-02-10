# Deploy Both JDK Versions

Now let's deploy our Kafka Streams application in both JDK 21 and JDK 26 versions, running side-by-side.

## Step 1: Deploy JDK 21 Version

Deploy the baseline application using JDK 21:

```bash
kubectl apply -f k8s/deployment-jdk21.yaml
```{{exec}}

This creates:
- Deployment with 1 replica
- Service exposing metrics on port 8080
- Resource limits: 2GB RAM, 2 CPU cores

## Step 2: Deploy JDK 26 Version

Now deploy the improved version using JDK 26:

```bash
kubectl apply -f k8s/deployment-jdk26.yaml
```{{exec}}

**Important:** Same application code, same resource limits, only difference is JDK version!

## Step 3: Watch Pods Starting

Monitor both deployments coming online:

```bash
kubectl get pods -l app=stock-processor -w
```{{exec}}

Wait until both pods show "1/1" in the READY column. This takes about 30-45 seconds. Press `Ctrl+C` when ready.

## Step 4: Verify Both Applications

Check that both versions are running:

```bash
kubectl get pods -l app=stock-processor
```{{exec}}

You should see:
- `stock-processor-jdk21-xxxxx` - Running
- `stock-processor-jdk26-xxxxx` - Running

## Step 5: Check Application Logs

Let's verify both applications connected to Kafka successfully.

**JDK 21 logs:**
```bash
kubectl logs -l version=jdk21 --tail=20
```{{exec}}

**JDK 26 logs:**
```bash
kubectl logs -l version=jdk26 --tail=20
```{{exec}}

You should see startup messages indicating the Kafka Streams topology initialized.

## Step 6: Verify Resource Allocation

Check the resource limits for both pods:

```bash
kubectl describe pod -l app=stock-processor | grep -A 5 "Limits:"
```{{exec}}

Both should have:
- Memory: 2Gi
- CPU: 2

This ensures a fair comparison - same resources, only JDK version differs.

## Understanding the Deployment Configuration

Let's look at the JDK 21 deployment configuration:

```bash
cat k8s/deployment-jdk21.yaml
```{{exec}}

Key settings:
- **Image:** `stock-processor:jdk21`
- **Replicas:** 1 (can be scaled up later)
- **Readiness probe:** HTTP GET on `/metrics` every 10 seconds
- **Environment variables:** Kafka bootstrap servers

The JDK 26 deployment is identical except for the image tag.

## What's Next?

Both applications are running and waiting for messages. Now we need to generate realistic load so we can compare their performance.

Click **Continue** to start the load generator.
