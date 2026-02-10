# Killercoda Tutorial: Java 26 GC Performance Demo

This directory contains a complete Killercoda tutorial demonstrating Java 26's garbage collection improvements using a Kafka Streams application.

## Tutorial Structure

```
killercoda-tutorial/
├── index.json              # Scenario configuration
├── intro.md                # Introduction page
├── background.sh           # Background setup script
├── foreground.sh           # Foreground setup script
├── step1.md                # Understanding the Challenge
├── step2.md                # Build the Application
├── step3.md                # Deploy Kafka Infrastructure
├── step4.md                # Deploy Both JDK Versions
├── step5.md                # Generate Realistic Load
├── step6.md                # Monitor Performance Difference
├── step7.md                # Analyze Detailed Metrics
├── step8.md                # Stress Test and Cost Analysis
├── finish.md               # Conclusion and next steps
└── README.md               # This file
```

## Publishing to Killercoda

### Prerequisites

1. A Killercoda account at https://killercoda.com
2. GitHub repository for hosting tutorial files
3. The `kafka-streams-demo.tar.gz` file (demo application)

### Step 1: Create GitHub Repository

1. Create a new GitHub repository named `killercoda-scenarios` (or similar)
2. Create a directory for this scenario: `java26-gc-demo/`
3. Upload all files from this directory to `java26-gc-demo/`

### Step 2: Prepare the Demo Asset

The tutorial expects `kafka-streams-demo.tar.gz` to be available as an asset.

**Option A: Include in repository**
```bash
# Create the tarball from your demo files
cd /path/to/demo
tar -czf kafka-streams-demo.tar.gz \
  src/ \
  k8s/ \
  scripts/ \
  Dockerfile.jdk21 \
  Dockerfile.jdk26 \
  pom.xml

# Add to repository
mv kafka-streams-demo.tar.gz /path/to/repo/java26-gc-demo/assets/
git add assets/
git commit -m "Add demo application asset"
git push
```

**Option B: Host externally**
Update `index.json` to download from external URL:
```json
"assets": {
  "host01": [
    {
      "file": "https://example.com/kafka-streams-demo.tar.gz",
      "target": "/root"
    }
  ]
}
```

### Step 3: Connect Repository to Killercoda

1. Go to https://killercoda.com/creator
2. Click "Import" or "Connect Repository"
3. Authorize Killercoda to access your GitHub account
4. Select your repository
5. Killercoda will automatically detect scenarios in your repository

### Step 4: Configure Scenario Settings

In the Killercoda UI:

1. **Title**: "Java 26 GC Performance: Kafka Streams Demo"
2. **Description**: "Hands-on comparison of GC performance between Java 21 and Java 26"
3. **Difficulty**: Intermediate
4. **Duration**: 30-45 minutes
5. **Tags**: java, kubernetes, kafka, performance, gc, streaming
6. **Visibility**: Public (or Private for testing)

### Step 5: Test the Scenario

Before publishing:

1. Click "Test" in Killercoda UI
2. Run through all steps to verify:
   - Setup scripts execute correctly
   - All commands work as expected
   - Assets download properly
   - Kubernetes resources deploy successfully
   - Performance differences are observable

### Step 6: Publish

Once tested and working:

1. Click "Publish" in Killercoda UI
2. Your scenario will be available at:
   `https://killercoda.com/varsharma/scenario/java26-gc-demo`

## Customization Options

### Adjust Kubernetes Resources

Edit `index.json` to change the Kubernetes environment:

```json
"backend": {
  "imageid": "kubernetes-kubeadm-2nodes"  // Options: kubernetes-kubeadm-1node, kubernetes-kubeadm-2nodes
}
```

### Add Additional Steps

To add more steps:

1. Create `stepX.md` file
2. Add to `index.json`:
```json
{
  "title": "New Step Title",
  "text": "stepX.md"
}
```

### Modify Setup Scripts

**background.sh** - Add more pre-installation:
- Additional tools
- Pre-pulled Docker images
- Downloaded dependencies

**foreground.sh** - Customize visible setup:
- Welcome messages
- Environment checks
- Instructions

## Troubleshooting

### Assets Not Loading

Ensure the asset path in `index.json` matches your repository structure:
```json
"assets": {
  "host01": [
    {
      "file": "kafka-streams-demo.tar.gz",
      "target": "/root"
    }
  ]
}
```

### Commands Not Executing

Verify `{{exec}}` markers are present in markdown files:
```markdown
```bash
kubectl get pods
```{{exec}}
```

### Kubernetes Not Ready

Increase timeout in background.sh:
```bash
kubectl wait --for=condition=Ready nodes --all --timeout=600s
```

## Best Practices

1. **Keep steps focused** - Each step should have one clear objective
2. **Test thoroughly** - Run through the entire scenario multiple times
3. **Provide context** - Explain what's happening, not just what to do
4. **Show expected output** - Users should know what success looks like
5. **Handle failures gracefully** - Add troubleshooting tips in steps

## Metrics to Monitor

After publishing, monitor:

- **Completion rate** - Are users finishing the tutorial?
- **Average duration** - How long does it take?
- **Drop-off points** - Where do users abandon?
- **User feedback** - Comments and ratings

## Maintenance

Periodically update:

- JDK versions as new releases come out
- Kubernetes manifests for API changes
- Performance metrics to reflect latest improvements
- Links to documentation

## Support

For Killercoda-specific questions:
- Documentation: https://killercoda.com/creators
- Community: Killercoda Slack/Discord
- Support: support@killercoda.com

For tutorial content questions:
- Open an issue in your GitHub repository
- Contact: varsharma on Killercoda

## License

This tutorial is provided as educational content. The demo application and Kafka Streams are subject to their respective licenses.

---

**Ready to publish?** Follow the steps above to make this tutorial available to the world!
