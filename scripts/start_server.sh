#!/bin/bash

# Log output to /tmp/deploy.log for debugging
exec > >(tee -a /tmp/deploy.log) 2>&1

echo "[INFO] Running start_server.sh"

# Check current user and directory
echo "[INFO] Whoami: $(whoami)"
echo "[INFO] Current directory: $(pwd)"
echo "[INFO] Listing contents:"
ls -la

# Create the app directory if it doesn't exist
mkdir -p /home/ec2-user/app

# Move to the app directory
cd /home/ec2-user/app || { echo "[ERROR] Failed to change directory"; exit 1; }

# Start a simple HTTP server in the background
nohup python3 -m http.server 80 &

echo "[INFO] Server started on port 80"
