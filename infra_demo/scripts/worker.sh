#!/bin/bash

# Wait for master node to be ready
sleep 30

# Install K3s worker node
# Note: In a real deployment, you would need to get the node token and master IP
# This is a simplified version for demonstration
curl -sfL https://get.k3s.io | K3S_URL=https://MASTER_IP:6443 K3S_TOKEN=NODE_TOKEN sh -
