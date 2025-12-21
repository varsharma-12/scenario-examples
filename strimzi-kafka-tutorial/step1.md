# Step 1: Install Strimzi Operator

The Strimzi operator manages Kafka clusters using Kubernetes Custom Resource Definitions (CRDs).

## Create Kafka Namespace

First, create a dedicated namespace for Kafka:
``````````````````````````````````````````````````````````````````````````````````````````````````````bash
kubectl create namespace kafka
`````````````````````````````````````````````````````````````````````````````````````````````````````{{exec}}

Verify the namespace:
````````````````````````````````````````````````````````````````````````````````````````````````````bash
kubectl get namespaces
```````````````````````````````````````````````````````````````````````````````````````````````````{{exec}}

## Install Strimzi Operator

Download and apply the Strimzi installation files:
``````````````````````````````````````````````````````````````````````````````````````````````````bash
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
`````````````````````````````````````````````````````````````````````````````````````````````````{{exec}}

This command installs:
- Custom Resource Definitions (CRDs) for Kafka, KafkaTopic, KafkaUser, etc.
- The Strimzi Cluster Operator deployment
- Required RBAC permissions

## Verify Installation

Watch the operator pod start up:
````````````````````````````````````````````````````````````````````````````````````````````````bash
kubectl get pods -n kafka -w
```````````````````````````````````````````````````````````````````````````````````````````````{{exec}}

Press `Ctrl+C` to stop watching once the pod shows `Running` status.

Check the operator logs:
``````````````````````````````````````````````````````````````````````````````````````````````bash
kubectl logs deployment/strimzi-cluster-operator -n kafka -f
`````````````````````````````````````````````````````````````````````````````````````````````{{exec}}

You should see logs indicating the operator is ready. Press `Ctrl+C` to exit.

## Explore Custom Resources

List the new CRDs installed by Strimzi:
````````````````````````````````````````````````````````````````````````````````````````````bash
kubectl get crd | grep strimzi
```````````````````````````````````````````````````````````````````````````````````````````{{exec}}

You should see:
- `kafkas.kafka.strimzi.io`
- `kafkatopics.kafka.strimzi.io`
- `kafkausers.kafka.strimzi.io`
- `kafkaconnects.kafka.strimzi.io`
- And more!

✅ **Checkpoint**: The Strimzi operator is now running and ready to manage Kafka clusters!
```````````````````````````````````````````````````````````````````````````````````````````

---

### **step2.md** (Deploy Kafka Cluster)
```````````````````````````````````````````````````````````````````````````````````````````markdown
# Step 2: Deploy Kafka Cluster

Now let's deploy a Kafka cluster with 3 brokers and 3 ZooKeeper nodes.

## Create Kafka Cluster

Create a file with the Kafka cluster definition:
``````````````````````````````````````````````````````````````````````````````````````````bash
cat <<EOF > kafka-cluster.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
  namespace: kafka
spec:
  kafka:
    version: 3.6.0
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      default.replication.factor: 3
      min.insync.replicas: 2
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF
`````````````````````````````````````````````````````````````````````````````````````````{{exec}}

Apply the configuration:
````````````````````````````````````````````````````````````````````````````````````````bash
kubectl apply -f kafka-cluster.yaml
```````````````````````````````````````````````````````````````````````````````````````{{exec}}

## Understanding the Configuration

Let's break down what we just created:

- **kafka.replicas: 3** - Three Kafka broker pods
- **listeners** - Two listeners (plain and TLS)
- **config** - Production-ready Kafka settings
- **storage: ephemeral** - Using emptyDir (for demo; use persistent-claim in production)
- **zookeeper.replicas: 3** - Three ZooKeeper nodes
- **entityOperator** - Manages topics and users

## Watch Deployment

Watch the pods being created:
``````````````````````````````````````````````````````````````````````````````````````bash
kubectl get pods -n kafka -w
`````````````````````````````````````````````````````````````````````````````````````{{exec}}

This will take 2-3 minutes. You should see:
- 3 ZooKeeper pods: `my-cluster-zookeeper-0/1/2`
- 3 Kafka broker pods: `my-cluster-kafka-0/1/2`
- Entity operator pod: `my-cluster-entity-operator-*`

Press `Ctrl+C` once all pods are `Running`.

## Verify Kafka Cluster

Check the Kafka resource status:
````````````````````````````````````````````````````````````````````````````````````bash
kubectl get kafka -n kafka
```````````````````````````````````````````````````````````````````````````````````{{exec}}

Get detailed information:
``````````````````````````````````````````````````````````````````````````````````bash
kubectl describe kafka my-cluster -n kafka
`````````````````````````````````````````````````````````````````````````````````{{exec}}

Check cluster services:
````````````````````````````````````````````````````````````````````````````````bash
kubectl get svc -n kafka
```````````````````````````````````````````````````````````````````````````````{{exec}}

You should see:
- `my-cluster-kafka-bootstrap` (for clients to connect)
- `my-cluster-kafka-brokers` (headless service)
- `my-cluster-zookeeper-nodes`

## Test Connectivity

Get the bootstrap service endpoint:
``````````````````````````````````````````````````````````````````````````````bash
kubectl get svc my-cluster-kafka-bootstrap -n kafka
`````````````````````````````````````````````````````````````````````````````{{exec}}

✅ **Checkpoint**: Your 3-node Kafka cluster is now running!
`````````````````````````````````````````````````````````````````````````````

---

### **step3.md** (Create Kafka Topics)
`````````````````````````````````````````````````````````````````````````````markdown
# Step 3: Create Kafka Topics

Strimzi allows you to manage Kafka topics as Kubernetes resources.

## Create a Topic Using kubectl

Create a topic definition:
````````````````````````````````````````````````````````````````````````````bash
cat <<EOF > my-topic.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: demo-topic
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 2
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF
```````````````````````````````````````````````````````````````````````````{{exec}}

Apply the topic:
``````````````````````````````````````````````````````````````````````````bash
kubectl apply -f my-topic.yaml
`````````````````````````````````````````````````````````````````````````{{exec}}

## Verify Topic Creation

List Kafka topics:
````````````````````````````````````````````````````````````````````````bash
kubectl get kafkatopics -n kafka
```````````````````````````````````````````````````````````````````````{{exec}}

Get topic details:
``````````````````````````````````````````````````````````````````````bash
kubectl describe kafkatopic demo-topic -n kafka
`````````````````````````````````````````````````````````````````````{{exec}}

## Create Topics Using Kafka Tools

You can also use native Kafka tools. First, exec into a Kafka pod:
````````````````````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --list
```````````````````````````````````````````````````````````````````{{exec}}

Create a topic using kafka-topics.sh:
``````````````````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --create \
  --topic manual-topic \
  --partitions 3 \
  --replication-factor 2
`````````````````````````````````````````````````````````````````{{exec}}

**Note**: Topics created manually won't be managed by the Topic Operator.

## Describe Topic Details
````````````````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --describe \
  --topic demo-topic
```````````````````````````````````````````````````````````````{{exec}}

You'll see partition assignments across brokers.

## Modify Topic Configuration

Update the topic retention:
``````````````````````````````````````````````````````````````bash
kubectl patch kafkatopic demo-topic -n kafka --type merge \
  -p '{"spec":{"config":{"retention.ms":"7200000"}}}'
`````````````````````````````````````````````````````````````{{exec}}

Verify the change:
````````````````````````````````````````````````````````````bash
kubectl get kafkatopic demo-topic -n kafka -o yaml
```````````````````````````````````````````````````````````{{exec}}

✅ **Checkpoint**: Topics created and managed via Kubernetes!
```````````````````````````````````````````````````````````

---

### **step4.md** (Produce and Consume Messages)
```````````````````````````````````````````````````````````markdown
# Step 4: Produce and Consume Messages

Let's test message production and consumption.

## Run Console Producer

Open a producer in one terminal:
``````````````````````````````````````````````````````````bash
kubectl run kafka-producer -ti \
  --image=quay.io/strimzi/kafka:latest-kafka-3.6.0 \
  --rm=true --restart=Never -n kafka -- \
  bin/kafka-console-producer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic demo-topic
`````````````````````````````````````````````````````````{{exec}}

Type some messages and press Enter after each:
`````````````````````````````````````````````````````````
Hello Kafka!
This is message 2
Testing Strimzi
``````````````````````````````````````````````````````````

Keep this terminal open for now.

## Run Console Consumer (New Terminal Tab)

Click the `+` icon to open a new terminal tab, then run:
``````````````````````````````````````````````````````````bash
kubectl run kafka-consumer -ti \
  --image=quay.io/strimzi/kafka:latest-kafka-3.6.0 \
  --rm=true --restart=Never -n kafka -- \
  bin/kafka-console-consumer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic demo-topic \
  --from-beginning
`````````````````````````````````````````````````````````{{exec}}

You should see all messages appear!

## Test with Consumer Groups

Exit the consumer (Ctrl+C) and start a new one with a group:
````````````````````````````````````````````````````````bash
kubectl run kafka-consumer-group -ti \
  --image=quay.io/strimzi/kafka:latest-kafka-3.6.0 \
  --rm=true --restart=Never -n kafka -- \
  bin/kafka-console-consumer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic demo-topic \
  --group my-consumer-group \
  --from-beginning
```````````````````````````````````````````````````````{{exec}}

## Check Consumer Group Status

In another terminal:
``````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-consumer-groups.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --describe \
  --group my-consumer-group
`````````````````````````````````````````````````````{{exec}}

You'll see lag, current offset, and partition assignments.

## Performance Test

Let's do a quick performance test. Producer test:
````````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-producer-perf-test.sh \
  --topic demo-topic \
  --num-records 10000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props bootstrap.servers=my-cluster-kafka-bootstrap:9092
```````````````````````````````````````````````````{{exec}}

Consumer test:
``````````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-consumer-perf-test.sh \
  --topic demo-topic \
  --messages 10000 \
  --bootstrap-server my-cluster-kafka-bootstrap:9092
`````````````````````````````````````````````````{{exec}}

✅ **Checkpoint**: Successfully produced and consumed messages!
`````````````````````````````````````````````````

---

### **step5.md** (Scale and Monitor)
`````````````````````````````````````````````````markdown
# Step 5: Scale and Monitor Kafka

Learn how to scale your Kafka cluster and monitor its health.

## Scale Kafka Brokers

Currently, we have 3 brokers. Let's scale to 5:
````````````````````````````````````````````````bash
kubectl patch kafka my-cluster -n kafka --type merge \
  -p '{"spec":{"kafka":{"replicas":5}}}'
```````````````````````````````````````````````{{exec}}

Watch the new pods being created:
``````````````````````````````````````````````bash
kubectl get pods -n kafka -w
`````````````````````````````````````````````{{exec}}

Press `Ctrl+C` once you see 5 Kafka pods running.

## Verify Scaling

Check broker IDs:
````````````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-broker-api-versions.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092
```````````````````````````````````````````{{exec}}

You should see 5 broker IDs (0-4).

## Monitor Cluster Health

Check pod resource usage:
``````````````````````````````````````````bash
kubectl top pods -n kafka
`````````````````````````````````````````{{exec}}

View broker logs:
````````````````````````````````````````bash
kubectl logs my-cluster-kafka-0 -n kafka --tail=50
```````````````````````````````````````{{exec}}

## Partition Reassignment

Create a topic to demonstrate rebalancing:
``````````````````````````````````````bash
cat <<EOF | kubectl apply -f -
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: test-rebalance
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 10
  replicas: 2
EOF
`````````````````````````````````````{{exec}}

Check partition distribution:
````````````````````````````````````bash
kubectl exec -it my-cluster-kafka-0 -n kafka -- \
  bin/kafka-topics.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --describe \
  --topic test-rebalance
```````````````````````````````````{{exec}}

Notice partitions might not be evenly distributed. In production, you'd use Cruise Control for auto-rebalancing.

## Rolling Update

Trigger a rolling restart (useful after configuration changes):
``````````````````````````````````bash
kubectl annotate kafka my-cluster -n kafka \
  strimzi.io/manual-rolling-update=true
`````````````````````````````````{{exec}}

Watch the rolling restart:
````````````````````````````````bash
kubectl get pods -n kafka -w
```````````````````````````````{{exec}}

Pods will restart one at a time. Press `Ctrl+C` when complete.

## Check Cluster Status

Get Kafka resource status:
``````````````````````````````bash
kubectl get kafka my-cluster -n kafka -o jsonpath='{.status.conditions[*].type}' | tr ' ' '\n'
`````````````````````````````{{exec}}

Should show: `Ready`

## Scale Down

Scale back to 3 brokers:
````````````````````````````bash
kubectl patch kafka my-cluster -n kafka --type merge \
  -p '{"spec":{"kafka":{"replicas":3}}}'
```````````````````````````{{exec}}

**Warning**: In production, ensure partitions are reassigned before scaling down!

✅ **Checkpoint**: Scaled and monitored Kafka cluster successfully!
```````````````````````````

---

### **step6.md** (Security and Authentication)
```````````````````````````markdown
# Step 6: Security and Authentication

Configure TLS encryption and SASL authentication.

## Create Kafka User with SCRAM-SHA-512
``````````````````````````bash
cat <<EOF > kafka-user.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: my-user
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
      - resource:
          type: topic
          name: demo-topic
          patternType: literal
        operations:
          - Read
          - Write
          - Describe
      - resource:
          type: group
          name: my-consumer-group
          patternType: literal
        operations:
          - Read
EOF
`````````````````````````{{exec}}

Apply the user:
````````````````````````bash
kubectl apply -f kafka-user.yaml
```````````````````````{{exec}}

## Retrieve User Credentials

Get the generated password:
``````````````````````bash
kubectl get secret my-user -n kafka -o jsonpath='{.data.password}' | base64 -d
`````````````````````{{exec}}

Save this password for later use.

## Update Kafka to Enable SASL
````````````````````bash
kubectl patch kafka my-cluster -n kafka --type merge -p '
{
  "spec": {
    "kafka": {
      "listeners": [
        {
          "name": "plain",
          "port": 9092,
          "type": "internal",
          "tls": false
        },
        {
          "name": "tls",
          "port": 9093,
          "type": "internal",
          "tls": true
        },
        {
          "name": "sasl",
          "port": 9094,
          "type": "internal",
          "tls": false,
          "authentication": {
            "type": "scram-sha-512"
          }
        }
      ]
    }
  }
}'
```````````````````{{exec}}

Wait for the rolling update:
``````````````````bash
kubectl get pods -n kafka -w
`````````````````{{exec}}

Press `Ctrl+C` when done.

## Test Authenticated Connection

Create a properties file for the producer:
````````````````bash
PASSWORD=$(kubectl get secret my-user -n kafka -o jsonpath='{.data.password}' | base64 -d)

cat <<EOF > /tmp/client.properties
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="my-user" password="$PASSWORD";
EOF
```````````````{{exec}}

Copy to a pod:
``````````````bash
POD=$(kubectl get pod -n kafka -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')
kubectl cp /tmp/client.properties kafka/$POD:/tmp/client.properties
`````````````{{exec}}

Test producer with authentication:
````````````bash
kubectl exec -it $POD -n kafka -- \
  bin/kafka-console-producer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9094 \
  --topic demo-topic \
  --producer.config /tmp/client.properties
```````````{{exec}}

Type a message and hit Enter, then Ctrl+C to exit.

## Test TLS Connection

Extract cluster CA certificate:
``````````bash
kubectl get secret my-cluster-cluster-ca-cert -n kafka \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/ca.crt
`````````{{exec}}

Create TLS properties:
````````bash
cat <<EOF > /tmp/tls-client.properties
security.protocol=SSL
ssl.truststore.location=/tmp/truststore.jks
ssl.truststore.password=changeit
EOF
```````{{exec}}

Create truststore:
``````bash
keytool -import -trustcacerts -alias root \
  -file /tmp/ca.crt \
  -keystore /tmp/truststore.jks \
  -storepass changeit -noprompt
`````{{exec}}

## View ACLs

Check the ACLs configured for our user:
````bash
kubectl exec -it $POD -n kafka -- \
  bin/kafka-acls.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --list \
  --topic demo-topic
```{{exec}}

✅ **Checkpoint**: Security configured with authentication and authorization!
```

---

### **finish.md**
```markdown
# Congratulations! 🎉

You've successfully completed the Strimzi Kafka on Kubernetes tutorial!

## What You've Learned

✅ Installed Strimzi Operator on Kubernetes
✅ Deployed a multi-broker Kafka cluster
✅ Created and managed topics declaratively
✅ Produced and consumed messages
✅ Scaled Kafka brokers dynamically
✅ Configured security with TLS and SASL authentication
✅ Set up ACLs for authorization

## Next Steps

### Explore More Features
- **Kafka Connect**: Deploy connectors for data integration
- **Kafka Bridge**: HTTP API for Kafka
- **Cruise Control**: Auto-rebalancing and cluster optimization
- **Monitoring**: Set up Prometheus and Grafana
- **KRaft Mode**: Deploy Kafka without ZooKeeper

### Production Considerations
- Use **persistent storage** instead of ephemeral
- Configure **resource requests/limits**
- Set up **pod anti-affinity** for high availability
- Enable **metrics and monitoring**
- Implement **backup and disaster recovery**
- Use **network policies** for security

### Resources

📚 **Documentation**
- [Strimzi Documentation](https://strimzi.io/docs/)
- [Strimzi Examples](https://github.com/strimzi/strimzi-kafka-operator/tree/main/examples)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)

💬 **Community**
- [Strimzi Slack](https://slack.cncf.io/) - #strimzi channel
- [GitHub Discussions](https://github.com/strimzi/strimzi-kafka-operator/discussions)
- [Mailing List](https://lists.cncf.io/g/cncf-strimzi-users)

🎓 **Advanced Topics**
- Multi-cluster deployment
- Geo-replication with MirrorMaker 2
- Custom authentication plugins
- Performance tuning

## Clean Up (Optional)

If you want to clean up the resources:

\`\`\`bash
kubectl delete kafka my-cluster -n kafka
kubectl delete kafkatopic --all -n kafka
kubectl delete kafkauser --all -n kafka
kubectl delete namespace kafka
\`\`\`

Thank you for completing this tutorial! Keep exploring Kafka on Kubernetes! 🚀
```

---

## **How to Deploy on Killercoda**

### **1. Create Account**
- Go to https://killercoda.com
- Sign up/login with GitHub

### **2. Create New Scenario**
- Click "Create Scenario"
- Choose "Kubernetes" environment
- Upload all files in the structure above

### **3. Test Your Scenario**
- Click "Preview" to test interactively
- Fix any issues
- Publish when ready

### **4. Share**
- Get shareable link
- Embed in blog posts
- Share at meetups

---

## **Additional Enhancements**

### **Add Verification Steps**

In each step, add verification scripts:
```bash
# verify.sh for step1
#!/bin/bash
if kubectl get pods -n kafka | grep -q "strimzi-cluster-operator"; then
  echo "done"
else
  echo "Operator not found"
  exit 1
fi
```

### **Add Hints**
```markdown
<details>
<summary>💡 Hint: Pod not starting?</summary>

Check the pod events:
\`\`\`bash
kubectl describe pod <pod-name> -n kafka
\`\`\`
</details>
```

### **Interactive Challenges**
```markdown
## Challenge: Create a Compacted Topic

Try creating a topic with log compaction enabled. Here's what you need:
- Topic name: `user-profiles`
- Partitions: 3
- Compaction enabled

<details>
<summary>Show Solution</summary>

\`\`\`yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: user-profiles
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 2
  config:
    cleanup.policy: compact
    segment.ms: 3600000
\`\`\`
</details>
```

---

Would you like me to:
1. Create the actual YAML files for the assets folder?
2. Add more advanced scenarios (Kafka Connect, monitoring)?
3. Create a GitHub repository with all files ready to deploy?
4. Add troubleshooting sections for common issues?
