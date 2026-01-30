#!/bin/bash

# Script to retrieve or reset passwords for Jenkins and SonarQube

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 ================================================${NC}"
echo -e "${BLUE}   PASSWORD RECOVERY & INFORMATION${NC}"
echo -e "${BLUE}==================================================${NC}\n"

# Jenkins Password
echo -e "${GREEN}📦 JENKINS${NC} (http://localhost:8080)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if docker ps --format '{{.Names}}' | grep -q '^jenkins$'; then
    if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        echo -e "${YELLOW}Initial Admin Password:${NC}"
        JENKINS_PASS=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
        echo -e "${GREEN}${JENKINS_PASS}${NC}"
        echo ""
        echo "Copy this password to login for the first time."
    else
        echo -e "${YELLOW}Status:${NC} Jenkins is already configured"
        echo ""
        echo -e "${RED}⚠️  Forgot your Jenkins password?${NC}"
        echo ""
        echo "Option 1: Reset Jenkins (loses all configuration):"
        echo "  ./reset-jenkins.sh"
        echo ""
        echo "Option 2: Manual reset:"
        echo "  1. docker stop jenkins"
        echo "  2. docker rm jenkins"
        echo "  3. docker volume rm jenkins_home"
        echo "  4. ./setup-jenkins.sh"
    fi
else
    echo -e "${RED}⚠️  Jenkins is not running${NC}"
    echo "Start it with: ./setup-jenkins.sh"
fi

echo -e "\n${GREEN}🔍 SONARQUBE${NC} (http://localhost:9000)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if docker ps --format '{{.Names}}' | grep -q '^sonarqube$'; then
    echo -e "${YELLOW}Default Credentials:${NC}"
    echo "  Username: admin"
    echo "  Password: admin"
    echo ""
    echo -e "${BLUE}ℹ️  First login:${NC} You'll be prompted to change the password"
    echo ""
    echo -e "${RED}⚠️  Forgot your SonarQube password after changing it?${NC}"
    echo ""
    echo "Option 1: Reset SonarQube (loses all data):"
    echo "  docker stop sonarqube"
    echo "  docker rm sonarqube"
    echo "  docker volume rm sonarqube_data sonarqube_logs sonarqube_extensions"
    echo "  ./setup-jenkins.sh"
    echo ""
    echo "Option 2: Reset admin password via database:"
    echo "  docker exec -it sonarqube sh"
    echo "  # Then manually reset in the database"
else
    echo -e "${RED}⚠️  SonarQube is not running${NC}"
    echo "Start it with:"
    echo "  docker start sonarqube  # If container exists"
    echo "  ./setup-jenkins.sh      # For fresh setup"
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}💡 Quick Actions:${NC}"
echo "  View this info:        ./get-passwords.sh"
echo "  Reset Jenkins:         ./reset-jenkins.sh"
echo "  Setup from scratch:    ./setup-jenkins.sh"
echo "  Check service status:  docker ps"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
