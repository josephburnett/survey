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
IMAGE_TAG="${IMAGE_BASE}:${COMMIT}"

# Configuration
REMOTE_HOST="home.local"
REMOTE_USER="joe"
SSH_KEY="$HOME/.ssh/home.local"
CONTAINER_NAME="routine-web-${COMMIT}"
IMAGE_BASE="josephburnett/routine"

# Read Rails master key from file
if [ ! -f "config/master.key" ]; then
    echo -e "${RED}❌ config/master.key file not found${NC}"
    exit 1
fi
RAILS_MASTER_KEY=$(cat config/master.key)

echo -e "${BLUE}Starting deployment process...${NC}"

echo -e "${YELLOW}Building and pushing image: ${IMAGE_TAG}${NC}"

# Build and push with Kamal
if ! kamal build push; then
    echo -e "${RED}Failed to build and push image with Kamal${NC}"
    exit 1
fi

echo -e "${GREEN}Image built and pushed successfully${NC}"

echo -e "${YELLOW}Deploying to ${REMOTE_HOST}...${NC}"

# Deploy to remote server
ssh -i "${SSH_KEY}" "${REMOTE_USER}@${REMOTE_HOST}" << EOF
    set -e
    
    echo "Stopping existing container (if running)..."
    if sudo docker ps -q -f name=${CONTAINER_NAME} | grep -q .; then
        echo "  Found running container, stopping..."
        sudo docker stop ${CONTAINER_NAME}
    else
        echo "  No running container found"
    fi
    
    echo "Removing existing container (if exists)..."
    if sudo docker ps -aq -f name=${CONTAINER_NAME} | grep -q .; then
        echo "  Found existing container, removing..."
        sudo docker rm ${CONTAINER_NAME}
    else
        echo "  No existing container found"
    fi
    
    echo "Pulling latest image..."
    sudo docker pull ${IMAGE_BASE}${IMAGE_TAG}
    
    echo "Starting new container..."
    sudo docker run -d \\
        -p 80:3000 \\
        -e RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \\
        -e RAILS_ENV=home \\
        --name ${CONTAINER_NAME} \\
        ${IMAGE_BASE}${IMAGE_TAG}
    
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
