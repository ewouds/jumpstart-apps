#!/bin/bash

# Install K3s master node
curl -sfL https://get.k3s.io | sh -

# Get the node token and save it to a file
sudo cat /var/lib/rancher/k3s/server/node-token > /home/${adminUsername}/node-token
