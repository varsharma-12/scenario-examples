# Step 6: Security and Authentication

Configure TLS encryption and SASL authentication.

## Create Kafka User with SCRAM-SHA-512
``````````````````````````bash
cat < kafka-user.yaml
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

cat < /tmp/client.properties
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
cat < /tmp/tls-client.properties
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
