#!/bin/bash

set -e  # Exit on any error
exec > >(tee /tmp/start_server.log) 2>&1  # Log output

echo "[INFO] Starting start_server.sh script..."

APP_DIR="/home/ec2-user/app"

# Create the app directory if it doesn't exist
echo "[INFO] Creating directory: $APP_DIR"
mkdir -p "$APP_DIR"

# Move to the app directory
cd "$APP_DIR"
echo "[INFO] Changed directory to $(pwd)"

# Copy the HTML file from the deployment archive
echo "[INFO] Copying index.html to $APP_DIR"
cp /home/ec2-user/DevopsProject1/index.html .

# Start the HTTP server
echo "[INFO] Starting HTTP server..."
nohup python3 -m http.server 80 &

echo "[INFO] HTTP server started successfully."
