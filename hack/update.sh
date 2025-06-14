#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current git commit hash (full hash to match Kamal)
COMMIT=$(git rev-parse HEAD)
IMAGE_REPO="josephburnett/routine"
FULL_IMAGE="${IMAGE_REPO}:${COMMIT}"

# Configuration
REMOTE_HOST="home.local"
REMOTE_USER="joe"
SSH_KEY="$HOME/.ssh/home.local"
CONTAINER_NAME="routine-web-${COMMIT}"

# Read Rails master key from file
if [ ! -f "config/master.key" ]; then
    echo -e "${RED}❌ config/master.key file not found${NC}"
    exit 1
fi
RAILS_MASTER_KEY=$(cat config/master.key)

echo -e "${YELLOW}Deploying to ${REMOTE_HOST}...${NC}"

# Deploy to remote server
ssh -i "${SSH_KEY}" "${REMOTE_USER}@${REMOTE_HOST}" << EOF
    set -e
    
    echo "Pulling latest image..."
    sudo docker pull ${FULL_IMAGE}

    # Debug: Show all running containers first
    echo "All running containers:"
    sudo docker ps
    
    # Get the container ID with explicit debugging
    echo "Searching for routine containers..."
    OLD_CONTAINER_ID=\$(sudo docker ps -q -f name=routine)
    echo "Found container ID: '\${OLD_CONTAINER_ID}'"
    echo "Container ID length: \${#OLD_CONTAINER_ID}"
    
    echo "Stopping existing container (if running)..."
    if [[ -n "\${OLD_CONTAINER_ID}" ]]; then
        echo "  Found running container \${OLD_CONTAINER_ID}, stopping..."
        sudo docker stop \${OLD_CONTAINER_ID}
    else
        echo "  No running container found"
    fi
    
    echo "Removing existing container (if exists)..."
    if [[ -n "\${OLD_CONTAINER_ID}" ]]; then
        echo "  Found existing container \${OLD_CONTAINER_ID}, removing..."
        sudo docker rm \${OLD_CONTAINER_ID}
    else
        echo "  No existing container found"
    fi
    
    echo "Starting new container..."
    sudo docker run -d \\
        -p 80:3000 \\
        -e RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \\
        -e RAILS_ENV=home \\
        --name ${CONTAINER_NAME} \\
        ${FULL_IMAGE}
    
    echo "Container started successfully"
    
    # Wait a moment for the container to start
    sleep 3
    
    echo "Container status:"
    sudo docker ps -f name=${CONTAINER_NAME}
    
    echo "Recent logs:"
    sudo docker logs --tail 20 ${CONTAINER_NAME}
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    echo -e "${BLUE}Application should be available at: http://${REMOTE_HOST}${NC}"
else
    echo -e "${RED}Deployment failed!${NC}"
    exit 1
fi
