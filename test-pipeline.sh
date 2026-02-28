#!/bin/bash

# Script pour tester manuellement le pipeline Jenkins
# Ce script exécute les mêmes étapes que Jenkins

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Test manuel du Pipeline Jenkins${NC}\n"

# Variables
export GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)
export DOCKER_REGISTRY="localhost"
export IMAGE_NAME="food-delivery"

echo -e "${GREEN}✅ Commit: ${GIT_COMMIT_SHORT}${NC}\n"

# 1. Install Dependencies
echo -e "${BLUE}📦 Installation des dépendances...${NC}"
cd backend && npm ci && cd ..
cd frontend && npm ci && cd ..
cd admin && npm ci && cd ..
echo -e "${GREEN}✅ Dépendances installées${NC}\n"

# 2. Build Docker Images
echo -e "${BLUE}🐳 Build des images Docker...${NC}"
docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-backend:${GIT_COMMIT_SHORT} ./backend
docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-frontend:${GIT_COMMIT_SHORT} ./frontend
docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-admin:${GIT_COMMIT_SHORT} ./admin
echo -e "${GREEN}✅ Images Docker créées${NC}\n"

# 3. Deploy to Staging
echo -e "${BLUE}🚀 Déploiement sur staging...${NC}"
docker-compose -f docker-compose.staging.yml down || true
docker-compose -f docker-compose.staging.yml up -d
echo -e "${GREEN}✅ Déployé sur staging${NC}\n"

echo -e "${GREEN}🎉 Test du pipeline terminé avec succès!${NC}"
echo -e "${BLUE}📋 Services disponibles:${NC}"
echo -e "   Backend Staging: http://localhost:4001"
echo -e "   Frontend Staging: http://localhost:3001"
echo -e "   Admin Staging: http://localhost:3002"
