#!/bin/bash

# Script to test Trivy security scanning locally
# This simulates the Jenkins Trivy stage

set -e

echo "=========================================="
echo "🔒 Trivy Security Scanning Test"
echo "=========================================="

# Configuration
DOCKER_REGISTRY="localhost"
IMAGE_NAME="food-delivery"
GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)

echo ""
echo "📋 Configuration:"
echo "   Registry: ${DOCKER_REGISTRY}"
echo "   Image Name: ${IMAGE_NAME}"
echo "   Tag: ${GIT_COMMIT_SHORT}"
echo ""

# Check if Docker is running
echo "🔍 Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi
echo "✅ Docker is running"
echo ""

# Check if images exist
echo "🔍 Checking if Docker images exist..."
IMAGES_EXIST=true

for component in backend frontend admin; do
    if docker images | grep -q "${IMAGE_NAME}-${component}"; then
        echo "   ✅ ${component} image found"
    else
        echo "   ⚠️  ${component} image not found"
        IMAGES_EXIST=false
    fi
done
echo ""

if [ "$IMAGES_EXIST" = false ]; then
    echo "⚠️  Some images are missing. Building them first..."
    echo ""
    
    # Build images
    echo "🔨 Building Docker images..."
    
    echo "   Building backend..."
    docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-backend:${GIT_COMMIT_SHORT} \
                 -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-backend:latest \
                 ./backend
    echo "   ✅ Backend built"
    
    echo "   Building frontend..."
    docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-frontend:${GIT_COMMIT_SHORT} \
                 -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-frontend:latest \
                 ./frontend
    echo "   ✅ Frontend built"
    
    echo "   Building admin..."
    docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-admin:${GIT_COMMIT_SHORT} \
                 -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-admin:latest \
                 ./admin
    echo "   ✅ Admin built"
    echo ""
fi

echo "=========================================="
echo "🔍 Starting Trivy Security Scans"
echo "=========================================="
echo ""

# Create reports directory
mkdir -p trivy-reports

# Scan Backend
echo "📦 Scanning Backend Image..."
echo "-------------------------------------------"
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/trivy-reports:/reports \
    aquasec/trivy:latest image \
    --severity HIGH,CRITICAL \
    --format json \
    --output /reports/trivy-backend-report.json \
    ${DOCKER_REGISTRY}/${IMAGE_NAME}-backend:${GIT_COMMIT_SHORT} || true

docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy:latest image \
    --severity HIGH,CRITICAL \
    ${DOCKER_REGISTRY}/${IMAGE_NAME}-backend:${GIT_COMMIT_SHORT} || true

echo ""
echo "✅ Backend scan completed"
echo ""

# Scan Frontend
echo "📦 Scanning Frontend Image..."
echo "-------------------------------------------"
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/trivy-reports:/reports \
    aquasec/trivy:latest image \
    --severity HIGH,CRITICAL \
    --format json \
    --output /reports/trivy-frontend-report.json \
    ${DOCKER_REGISTRY}/${IMAGE_NAME}-frontend:${GIT_COMMIT_SHORT} || true

docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy:latest image \
    --severity HIGH,CRITICAL \
    ${DOCKER_REGISTRY}/${IMAGE_NAME}-frontend:${GIT_COMMIT_SHORT} || true

echo ""
echo "✅ Frontend scan completed"
echo ""

# Scan Admin
echo "📦 Scanning Admin Image..."
echo "-------------------------------------------"
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/trivy-reports:/reports \
    aquasec/trivy:latest image \
    --severity HIGH,CRITICAL \
    --format json \
    --output /reports/trivy-admin-report.json \
    ${DOCKER_REGISTRY}/${IMAGE_NAME}-admin:${GIT_COMMIT_SHORT} || true

docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy:latest image \
    --severity HIGH,CRITICAL \
    ${DOCKER_REGISTRY}/${IMAGE_NAME}-admin:${GIT_COMMIT_SHORT} || true

echo ""
echo "✅ Admin scan completed"
echo ""

echo "=========================================="
echo "✅ Trivy Security Scanning Completed!"
echo "=========================================="
echo ""
echo "📊 Reports saved in: ./trivy-reports/"
echo ""
echo "📁 Generated reports:"
ls -lh trivy-reports/ 2>/dev/null || echo "   No reports found"
echo ""
echo "💡 To view detailed report:"
echo "   cat trivy-reports/trivy-backend-report.json | jq"
echo "   cat trivy-reports/trivy-frontend-report.json | jq"
echo "   cat trivy-reports/trivy-admin-report.json | jq"
echo ""
