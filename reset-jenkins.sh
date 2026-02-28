#!/bin/bash

# Script to reset Jenkins to factory defaults

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  ================================================${NC}"
echo -e "${RED}   JENKINS RESET - ALL DATA WILL BE LOST!${NC}"
echo -e "${RED}==================================================${NC}\n"

echo -e "${YELLOW}This will:${NC}"
echo "  1. Stop the Jenkins container"
echo "  2. Remove the Jenkins container"
echo "  3. Delete all Jenkins data (jobs, plugins, users, etc.)"
echo "  4. Create a fresh Jenkins instance"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${BLUE}Reset cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Stopping Jenkins...${NC}"
docker stop jenkins 2>/dev/null || true

echo -e "${BLUE}Step 2: Removing Jenkins container...${NC}"
docker rm jenkins 2>/dev/null || true

echo -e "${BLUE}Step 3: Removing Jenkins volume...${NC}"
docker volume rm jenkins_home 2>/dev/null || true

echo -e "${BLUE}Step 4: Creating fresh Jenkins instance...${NC}"
docker run -d \
    --name jenkins \
    -p 8080:8080 \
    -p 50000:50000 \
    --network food-delivery-network \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:lts

echo ""
echo -e "${GREEN}✅ Jenkins has been reset!${NC}"
echo ""
echo "Waiting for Jenkins to start (30 seconds)..."
sleep 30

if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    JENKINS_PASS=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
    echo ""
    echo -e "${GREEN}🔐 Your new Jenkins password:${NC}"
    echo -e "${YELLOW}${JENKINS_PASS}${NC}"
    echo ""
    echo -e "${BLUE}Access Jenkins at: http://localhost:8080${NC}"
else
    echo ""
    echo -e "${YELLOW}Jenkins is still starting. Get the password with:${NC}"
    echo "  docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
fi

echo ""
