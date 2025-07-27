#!/bin/bash
set -e  # Exit on any error

# Log output
exec > >(tee /tmp/stop_server.log) 2>&1
echo "[INFO] Starting stop_server.sh script..."

# Stop the HTTP server if running
echo "[INFO] Stopping any running HTTP server..."
pkill -f "python3 -m http.server" || echo "[INFO] No existing HTTP server to stop."

echo "[INFO] stop_server.sh script completed."
