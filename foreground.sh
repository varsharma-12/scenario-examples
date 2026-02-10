#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Java 26 GC Performance Demo - Environment Setup             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Setting up your demo environment..."
echo "⏳ This will take about 30-60 seconds"
echo ""

# Wait for background setup to complete
while [ ! -f /tmp/setup-complete ]; do
    sleep 2
done

echo "✅ Kubernetes cluster ready"
echo "✅ Maven installed"
echo "✅ Python dependencies installed"
echo "✅ Demo files extracted"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Environment ready! Click 'Start' to begin the tutorial."
echo "═══════════════════════════════════════════════════════════════"
