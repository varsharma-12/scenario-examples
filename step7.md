# Analyze Detailed Metrics

Both applications expose Prometheus metrics on port 8080. Let's dive into the detailed performance data.

## Step 1: Access JDK 21 Metrics

Port-forward to the JDK 21 service:

```bash
kubectl port-forward svc/stock-processor-jdk21 8081:8080 > /dev/null 2>&1 &
```{{exec}}

Query the metrics endpoint:

```bash
curl -s http://localhost:8081/metrics | grep -E "trade_processing|jvm_gc" | head -20
```{{exec}}

## Step 2: Access JDK 26 Metrics

Port-forward to the JDK 26 service:

```bash
kubectl port-forward svc/stock-processor-jdk26 8082:8080 > /dev/null 2>&1 &
```{{exec}}

Query the metrics endpoint:

```bash
curl -s http://localhost:8082/metrics | grep -E "trade_processing|jvm_gc" | head -20
```{{exec}}

## Step 3: Compare Processing Latency

Extract latency percentiles from both:

```bash
echo "=== JDK 21 Latency Distribution ==="
curl -s http://localhost:8081/metrics | grep "trade_processing_time_seconds{quantile"

echo ""
echo "=== JDK 26 Latency Distribution ==="
curl -s http://localhost:8082/metrics | grep "trade_processing_time_seconds{quantile"
```{{exec}}

**Key metrics:**
- `quantile="0.5"` - Median (P50) latency
- `quantile="0.95"` - P95 latency
- `quantile="0.99"` - P99 latency (critical for SLAs)

**Expected difference:** JDK 26 should show ~50% lower P99 latency.

## Step 4: Compare GC Pause Times

```bash
echo "=== JDK 21 GC Pause Statistics ==="
curl -s http://localhost:8081/metrics | grep "jvm_gc_pause_seconds"

echo ""
echo "=== JDK 26 GC Pause Statistics ==="
curl -s http://localhost:8082/metrics | grep "jvm_gc_pause_seconds"
```{{exec}}

**Key metrics:**
- `jvm_gc_pause_seconds_sum` - Total time spent in GC
- `jvm_gc_pause_seconds_count` - Number of GC pauses
- Calculate average: sum / count

**Expected difference:** JDK 26 should show ~47% less total GC time.

## Step 5: Compare Memory Usage

```bash
echo "=== JDK 21 Memory Usage ==="
curl -s http://localhost:8081/metrics | grep "jvm_memory_used_bytes{area=\"heap\""

echo ""
echo "=== JDK 26 Memory Usage ==="
curl -s http://localhost:8082/metrics | grep "jvm_memory_used_bytes{area=\"heap\""
```{{exec}}

Both use similar amounts of heap memory, but JDK 26 manages it more efficiently.

## Step 6: Throughput Comparison

Count total messages processed:

```bash
echo "=== JDK 21 Total Messages Processed ==="
curl -s http://localhost:8081/metrics | grep "trade_processing_time_seconds_count"

echo ""
echo "=== JDK 26 Total Messages Processed ==="
curl -s http://localhost:8082/metrics | grep "trade_processing_time_seconds_count"
```{{exec}}

**Expected difference:** JDK 26 processes ~4% more messages in the same time period.

## Step 7: Calculate Concrete Improvements

Let's create a simple comparison script:

```bash
cat > /tmp/compare.sh << 'EOF'
#!/bin/bash
echo "Performance Comparison Report"
echo "==============================="
echo ""

# JDK 21 metrics
p99_jdk21=$(curl -s http://localhost:8081/metrics | grep 'trade_processing_time_seconds{quantile="0.99"' | awk '{print $2}')
gc_sum_jdk21=$(curl -s http://localhost:8081/metrics | grep 'jvm_gc_pause_seconds_sum' | awk '{print $2}')
gc_count_jdk21=$(curl -s http://localhost:8081/metrics | grep 'jvm_gc_pause_seconds_count' | awk '{print $2}')

# JDK 26 metrics  
p99_jdk26=$(curl -s http://localhost:8082/metrics | grep 'trade_processing_time_seconds{quantile="0.99"' | awk '{print $2}')
gc_sum_jdk26=$(curl -s http://localhost:8082/metrics | grep 'jvm_gc_pause_seconds_sum' | awk '{print $2}')
gc_count_jdk26=$(curl -s http://localhost:8082/metrics | grep 'jvm_gc_pause_seconds_count' | awk '{print $2}')

echo "P99 Latency:"
echo "  JDK 21: ${p99_jdk21}s"
echo "  JDK 26: ${p99_jdk26}s"
echo ""

echo "Average GC Pause:"
echo "  JDK 21: $(echo "scale=4; $gc_sum_jdk21 / $gc_count_jdk21 * 1000" | bc)ms"
echo "  JDK 26: $(echo "scale=4; $gc_sum_jdk26 / $gc_count_jdk26 * 1000" | bc)ms"
echo ""

echo "Total GC Time:"
echo "  JDK 21: ${gc_sum_jdk21}s"
echo "  JDK 26: ${gc_sum_jdk26}s"
EOF

chmod +x /tmp/compare.sh
/tmp/compare.sh
```{{exec}}

## Understanding the Metrics

**Prometheus metrics format:**
```
# HELP - Description of the metric
# TYPE - Metric type (counter, gauge, summary, histogram)
metric_name{label="value"} actual_value
```

Our application exposes:
- **Counters** - Monotonically increasing (total messages)
- **Summaries** - Statistical distribution (latency percentiles)
- **Gauges** - Point-in-time values (memory usage)

## Real-World Impact

These metrics translate to real business value:

**For 100 pods in production:**
- 47% less GC time = 400 fewer CPU cores needed
- 50% better P99 latency = Fewer SLA violations
- 4% more throughput = Handle more traffic without scaling
- 86% fewer probe failures = More stable operations

**Annual cost savings:** ~$17,000 for 100 pods (at typical cloud pricing)

## What's Next?

We've analyzed detailed metrics showing significant improvements. Now let's stress-test the system to see how both versions handle extreme load.

Click **Continue** for stress testing and cost analysis.
