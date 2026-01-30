#!/bin/bash

# Script to reset SonarQube admin password

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  ================================================${NC}"
echo -e "${RED}   SONARQUBE RESET - ALL DATA WILL BE LOST!${NC}"
echo -e "${RED}==================================================${NC}\n"

echo -e "${YELLOW}This will:${NC}"
echo "  1. Stop SonarQube"
echo "  2. Remove the container"
echo "  3. Delete all SonarQube data (projects, users, settings, etc.)"
echo "  4. Create a fresh SonarQube instance"
echo "  5. Reset to default credentials (admin/admin)"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${BLUE}Reset cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Stopping SonarQube...${NC}"
docker stop sonarqube 2>/dev/null || true

echo -e "${BLUE}Step 2: Removing SonarQube container...${NC}"
docker rm sonarqube 2>/dev/null || true

echo -e "${BLUE}Step 3: Removing SonarQube volumes...${NC}"
docker volume rm sonarqube_data 2>/dev/null || true
docker volume rm sonarqube_logs 2>/dev/null || true
docker volume rm sonarqube_extensions 2>/dev/null || true

echo -e "${BLUE}Step 4: Creating fresh SonarQube instance...${NC}"
docker run -d \
    --name sonarqube \
    -p 9000:9000 \
    --network food-delivery-network \
    -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_logs:/opt/sonarqube/logs \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    sonarqube:lts-community

echo ""
echo -e "${GREEN}✅ SonarQube has been reset!${NC}"
echo ""
echo "Waiting for SonarQube to start (this takes about 45 seconds)..."
sleep 45

echo ""
echo -e "${GREEN}🔐 Your SonarQube credentials:${NC}"
echo -e "${YELLOW}URL:      ${NC}http://localhost:9000"
echo -e "${YELLOW}Username: ${NC}admin"
echo -e "${YELLOW}Password: ${NC}admin"
echo ""
echo -e "${RED}⚠️  Important: Change the password on first login!${NC}"
echo ""
