# Monitor Performance Difference

Now comes the exciting part - watching the performance difference in real-time!

## Step 1: Open Split Terminal View

For the best experience, you'll want to see both applications side-by-side. 

**In Killercoda:** Click the terminal split button to create a second terminal pane.

## Step 2: Watch JDK 21 Performance (Terminal 1)

In the first terminal, monitor JDK 21:

```bash
kubectl logs -f -l version=jdk21 | grep "Messages Processed"
```{{exec}}

## Step 3: Watch JDK 26 Performance (Terminal 2)

In the second terminal (or in a new terminal window), monitor JDK 26:

```bash
kubectl logs -f -l version=jdk26 | grep "Messages Processed"
```{{exec}}

## What You'll See

Let these run for 1-2 minutes. You'll observe patterns like:

**JDK 21 (Baseline):**
```
Messages Processed: 56842 | Avg Latency: 38.42ms | P99: 156.23ms
[GC pause (G1 Evacuation Pause) 18.234ms]
Messages Processed: 57120 | Avg Latency: 41.18ms | P99: 168.45ms
[GC pause (G1 Evacuation Pause) 24.567ms]
```

**JDK 26 (Improved):**
```
Messages Processed: 59123 | Avg Latency: 24.18ms | P99: 78.34ms
[GC pause (G1 Evacuation Pause) 8.123ms]
Messages Processed: 59401 | Avg Latency: 23.92ms | P99: 76.12ms
[GC pause (G1 Evacuation Pause) 7.845ms]
```

## Key Differences to Notice

Press `Ctrl+C` in both terminals after observing the patterns.

### 1. Processing Throughput
```bash
# Count messages processed in last minute for JDK 21
kubectl logs -l version=jdk21 --since=1m | grep "Messages Processed" | tail -5

# Count messages processed in last minute for JDK 26
kubectl logs -l version=jdk26 --since=1m | grep "Messages Processed" | tail -5
```{{exec}}

**Observation:** JDK 26 processes more messages in the same time period.

### 2. GC Pause Times
```bash
# Extract recent GC pauses for JDK 21
kubectl logs -l version=jdk21 --since=2m | grep "GC pause" | tail -10

# Extract recent GC pauses for JDK 26
kubectl logs -l version=jdk26 --since=2m | grep "GC pause" | tail -10
```{{exec}}

**Observation:** JDK 26 has significantly shorter pause times.

### 3. Latency Comparison
```bash
# Get average latencies from recent logs
echo "JDK 21 recent latencies:"
kubectl logs -l version=jdk21 --tail=20 | grep "Avg Latency" | tail -5

echo ""
echo "JDK 26 recent latencies:"
kubectl logs -l version=jdk26 --tail=20 | grep "Avg Latency" | tail -5
```{{exec}}

**Observation:** JDK 26 maintains lower and more consistent latency.

## Step 4: Check Kubernetes Health

GC pauses can cause Kubernetes readiness probe failures. Let's check:

```bash
kubectl get events --sort-by='.lastTimestamp' | grep "Readiness probe failed" | tail -10
```{{exec}}

**What to look for:**
- JDK 21 pods may show some probe failures during long GC pauses
- JDK 26 pods should show few or no failures

## Step 5: Resource Utilization

Check CPU and memory usage:

```bash
kubectl top pods -l app=stock-processor
```{{exec}}

**Observation:** Despite processing the same (or more) messages, JDK 26 typically uses less CPU.

## Why This Happens

The differences you're seeing are due to Java 26's G1GC improvements:

1. **Concurrent Refinement** - More GC work happens without pausing the application
2. **Adaptive Regions** - Better heap organization reduces the need for long pauses
3. **Smarter Evacuation** - More efficient memory compaction algorithms

All of this happens **automatically** - no code changes required!

## Quick Summary So Far

After just a few minutes of observation, you should see:
- ✅ Shorter GC pauses (47-50% reduction)
- ✅ Lower average latency
- ✅ Better P99 latency (fewer outliers)
- ✅ More consistent throughput
- ✅ Fewer health check issues

## What's Next?

We've seen the differences in real-time logs. Now let's dive into detailed Prometheus metrics for a more comprehensive analysis.

Click **Continue** to analyze detailed metrics.
