#!/bin/bash

# Local DAST Testing Script
# Runs OWASP ZAP scans against running Docker Compose services

echo "=========================================="
echo "🔐 Local DAST Testing with OWASP ZAP"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker Compose services are running
echo -e "${BLUE}Checking if services are running...${NC}"
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Services not running. Starting docker-compose...${NC}"
    docker-compose up -d
    echo "Waiting 30 seconds for services to start..."
    sleep 30
fi

# Create reports directory
mkdir -p zap-reports-local

# Check service availability
echo -e "\n${BLUE}Checking service availability...${NC}"

if curl -f -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✅ Frontend (http://localhost:3000) is accessible${NC}"
else
    echo -e "${RED}⚠️  Frontend is not accessible${NC}"
fi

if curl -f -s http://localhost:4000/api/health > /dev/null; then
    echo -e "${GREEN}✅ Backend (http://localhost:4000) is accessible${NC}"
else
    echo -e "${RED}⚠️  Backend is not accessible${NC}"
fi

if curl -f -s http://localhost:3001 > /dev/null; then
    echo -e "${GREEN}✅ Admin (http://localhost:3001) is accessible${NC}"
else
    echo -e "${RED}⚠️  Admin is not accessible${NC}"
fi

# Run ZAP baseline scans
echo -e "\n=========================================="
echo -e "${BLUE}Running OWASP ZAP Baseline Scans${NC}"
echo "=========================================="

# Frontend scan
echo -e "\n${BLUE}1/3 Scanning Frontend (http://localhost:3000)...${NC}"
docker run --rm \
    --network host \
    -v "$(pwd)/zap-reports-local:/zap/wrk:rw" \
    ghcr.io/zaproxy/zaproxy:stable \
    zap-baseline.py \
    -t http://localhost:3000 \
    -r frontend-report.html \
    -J frontend-report.json \
    -w frontend-report.md \
    -I \
    || echo -e "${YELLOW}⚠️  ZAP found some issues (this is normal)${NC}"

echo -e "${GREEN}✅ Frontend scan completed${NC}"

# Backend scan
echo -e "\n${BLUE}2/3 Scanning Backend API (http://localhost:4000)...${NC}"
docker run --rm \
    --network host \
    -v "$(pwd)/zap-reports-local:/zap/wrk:rw" \
    ghcr.io/zaproxy/zaproxy:stable \
    zap-baseline.py \
    -t http://localhost:4000 \
    -r backend-report.html \
    -J backend-report.json \
    -w backend-report.md \
    -I \
    || echo -e "${YELLOW}⚠️  ZAP found some issues (this is normal)${NC}"

echo -e "${GREEN}✅ Backend scan completed${NC}"

# Admin scan
echo -e "\n${BLUE}3/3 Scanning Admin (http://localhost:3001)...${NC}"
docker run --rm \
    --network host \
    -v "$(pwd)/zap-reports-local:/zap/wrk:rw" \
    ghcr.io/zaproxy/zaproxy:stable \
    zap-baseline.py \
    -t http://localhost:3001 \
    -r admin-report.html \
    -J admin-report.json \
    -w admin-report.md \
    -I \
    || echo -e "${YELLOW}⚠️  ZAP found some issues (this is normal)${NC}"

echo -e "${GREEN}✅ Admin scan completed${NC}"

# Generate summary
echo -e "\n=========================================="
echo -e "${GREEN}✅ DAST Scanning Completed!${NC}"
echo "=========================================="
echo ""
echo "📊 Reports generated in: zap-reports-local/"
echo ""
echo "Available reports:"
echo "  - frontend-report.html (Open in browser)"
echo "  - backend-report.html (Open in browser)"
echo "  - admin-report.html (Open in browser)"
echo ""
echo "View reports:"
echo "  open zap-reports-local/frontend-report.html"
echo "  open zap-reports-local/backend-report.html"
echo "  open zap-reports-local/admin-report.html"
echo ""
echo "=========================================="

# Parse and display summary from JSON reports
echo -e "\n${BLUE}Security Scan Summary:${NC}"
echo "=========================================="

for component in frontend backend admin; do
    report_file="zap-reports-local/${component}-report.json"
    if [ -f "$report_file" ]; then
        echo -e "\n${YELLOW}${component^}:${NC}"
        
        # Extract alerts count by risk level using grep and wc
        high=$(grep -o '"risk": "High"' "$report_file" 2>/dev/null | wc -l | tr -d ' ')
        medium=$(grep -o '"risk": "Medium"' "$report_file" 2>/dev/null | wc -l | tr -d ' ')
        low=$(grep -o '"risk": "Low"' "$report_file" 2>/dev/null | wc -l | tr -d ' ')
        info=$(grep -o '"risk": "Informational"' "$report_file" 2>/dev/null | wc -l | tr -d ' ')
        
        echo "  High: $high"
        echo "  Medium: $medium"
        echo "  Low: $low"
        echo "  Informational: $info"
    fi
done

echo ""
echo "=========================================="
echo -e "${BLUE}Common Security Recommendations:${NC}"
echo "=========================================="
echo "1. Implement Content Security Policy (CSP)"
echo "2. Add Anti-CSRF tokens"
echo "3. Enable HTTP Strict Transport Security (HSTS)"
echo "4. Set X-Frame-Options header"
echo "5. Implement rate limiting"
echo "6. Use secure session management"
echo "7. Validate and sanitize all inputs"
echo "8. Keep dependencies up to date"
echo ""
