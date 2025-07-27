#!/bin/bash

# Create the app directory if it doesn't exist
mkdir -p /home/ec2-user/app

# Move to the app directory
cd /home/ec2-user/app

# Start a simple HTTP server in the background
nohup python3 -m http.server 80 &
