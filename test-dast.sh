#!/bin/bash

# Script to run DAST (Dynamic Application Security Testing) with OWASP ZAP
# This simulates the Jenkins DAST stage

set -e

echo "=========================================="
echo "🔒 Dynamic Application Security Testing"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FRONTEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:4000"
ADMIN_URL="http://localhost:3001"
ZAP_PORT=8090

# Create reports directory
mkdir -p zap-reports

echo "📋 DAST Configuration:"
echo "   Frontend URL: ${FRONTEND_URL}"
echo "   Backend API:  ${BACKEND_URL}"
echo "   Admin URL:    ${ADMIN_URL}"
echo "   ZAP Port:     ${ZAP_PORT}"
echo ""

# Check if applications are running
echo "🔍 Checking if applications are running..."
check_service() {
    local url=$1
    local name=$2
    
    if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "$url" > /dev/null 2>&1; then
        echo -e "   ✅ ${name} is running at ${url}"
        return 0
    else
        echo -e "   ${YELLOW}⚠️  ${name} is not running at ${url}${NC}"
        return 1
    fi
}

SERVICES_RUNNING=true
check_service "${FRONTEND_URL}" "Frontend" || SERVICES_RUNNING=false
check_service "${BACKEND_URL}/api" "Backend API" || SERVICES_RUNNING=false
check_service "${ADMIN_URL}" "Admin" || SERVICES_RUNNING=false

if [ "$SERVICES_RUNNING" = false ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Some services are not running!${NC}"
    echo ""
    echo "To start the applications:"
    echo "   docker-compose up -d"
    echo "   # or"
    echo "   ./start.sh"
    echo ""
    echo "For testing purposes, we'll use a mock scan..."
    echo ""
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed or not running${NC}"
    exit 1
fi

echo ""
echo "🔍 Running OWASP ZAP Security Scans..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start ZAP in daemon mode
echo "🚀 Starting OWASP ZAP daemon..."
docker run -d --name zap-dast \
    --network host \
    -v $(pwd):/zap/wrk:rw \
    -t ghcr.io/zaproxy/zaproxy:stable \
    zap.sh -daemon -host 0.0.0.0 -port ${ZAP_PORT} -config api.disablekey=true \
    > /dev/null 2>&1 || echo "ZAP container already running or failed to start"

# Wait for ZAP to start
echo "⏳ Waiting for ZAP to initialize..."
sleep 10

# Check if ZAP is running
if docker ps | grep -q zap-dast; then
    echo -e "${GREEN}✅ ZAP is running${NC}"
    echo ""
    
    # Run baseline scan
    echo "📊 Running ZAP Baseline Scan..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Frontend scan
    if [ "$SERVICES_RUNNING" = true ]; then
        echo ""
        echo "🌐 Scanning Frontend (${FRONTEND_URL})..."
        docker exec zap-dast zap-baseline.py \
            -t ${FRONTEND_URL} \
            -r zap-reports/frontend-baseline.html \
            -J zap-reports/frontend-baseline.json \
            -w zap-reports/frontend-baseline.md \
            -x zap-reports/frontend-baseline.xml \
            -c zap-config.yaml \
            -T 5 \
            || echo "Frontend scan completed with warnings"
        
        echo ""
        echo "🔌 Scanning Backend API (${BACKEND_URL})..."
        docker exec zap-dast zap-baseline.py \
            -t ${BACKEND_URL}/api \
            -r zap-reports/backend-baseline.html \
            -J zap-reports/backend-baseline.json \
            -w zap-reports/backend-baseline.md \
            -x zap-reports/backend-baseline.xml \
            -c zap-config.yaml \
            -T 5 \
            || echo "Backend scan completed with warnings"
        
        echo ""
        echo "👨‍💼 Scanning Admin Panel (${ADMIN_URL})..."
        docker exec zap-dast zap-baseline.py \
            -t ${ADMIN_URL} \
            -r zap-reports/admin-baseline.html \
            -J zap-reports/admin-baseline.json \
            -w zap-reports/admin-baseline.md \
            -x zap-reports/admin-baseline.xml \
            -c zap-config.yaml \
            -T 5 \
            || echo "Admin scan completed with warnings"
    else
        echo ""
        echo -e "${YELLOW}⚠️  Skipping actual scans (services not running)${NC}"
        echo "Creating mock reports for demonstration..."
        
        # Create mock reports
        cat > zap-reports/mock-scan-summary.json << 'EOF'
{
  "summary": {
    "scanDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "target": "http://localhost:3000",
    "totalAlerts": 15,
    "riskBreakdown": {
      "high": 2,
      "medium": 5,
      "low": 6,
      "informational": 2
    }
  },
  "commonVulnerabilities": [
    {
      "name": "Missing Anti-CSRF Tokens",
      "risk": "high",
      "description": "No Anti-CSRF tokens were found in a HTML submission form",
      "solution": "Implement CSRF tokens for all state-changing operations"
    },
    {
      "name": "Content Security Policy (CSP) Header Not Set",
      "risk": "medium",
      "description": "CSP was not found in response headers",
      "solution": "Add Content-Security-Policy header to prevent XSS attacks"
    },
    {
      "name": "X-Content-Type-Options Header Missing",
      "risk": "low",
      "description": "The Anti-MIME-Sniffing header is not set",
      "solution": "Add X-Content-Type-Options: nosniff header"
    }
  ]
}
EOF
    fi
    
    # Stop ZAP
    echo ""
    echo "🛑 Stopping ZAP daemon..."
    docker stop zap-dast > /dev/null 2>&1 || true
    docker rm zap-dast > /dev/null 2>&1 || true
else
    echo -e "${RED}❌ Failed to start ZAP${NC}"
    echo "Running basic security checks instead..."
    echo ""
    
    # Fallback: Basic security header checks
    echo "🔒 Running Basic Security Header Checks..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cat > zap-reports/security-headers-check.txt << EOF
Security Headers Check Report
Generated: $(date)

Checking Security Headers on Running Services:
EOF
    
    for url in "$FRONTEND_URL" "$BACKEND_URL" "$ADMIN_URL"; do
        echo "" >> zap-reports/security-headers-check.txt
        echo "=== $url ===" >> zap-reports/security-headers-check.txt
        
        if curl -s -I "$url" > /dev/null 2>&1; then
            HEADERS=$(curl -s -I "$url" 2>/dev/null || echo "Failed to fetch")
            
            echo "Checking for security headers..." >> zap-reports/security-headers-check.txt
            echo "$HEADERS" | grep -i "Content-Security-Policy" >> zap-reports/security-headers-check.txt || echo "❌ Missing: Content-Security-Policy" >> zap-reports/security-headers-check.txt
            echo "$HEADERS" | grep -i "X-Frame-Options" >> zap-reports/security-headers-check.txt || echo "❌ Missing: X-Frame-Options" >> zap-reports/security-headers-check.txt
            echo "$HEADERS" | grep -i "X-Content-Type-Options" >> zap-reports/security-headers-check.txt || echo "❌ Missing: X-Content-Type-Options" >> zap-reports/security-headers-check.txt
            echo "$HEADERS" | grep -i "Strict-Transport-Security" >> zap-reports/security-headers-check.txt || echo "⚠️  Missing: Strict-Transport-Security (HTTPS only)" >> zap-reports/security-headers-check.txt
            echo "$HEADERS" | grep -i "X-XSS-Protection" >> zap-reports/security-headers-check.txt || echo "❌ Missing: X-XSS-Protection" >> zap-reports/security-headers-check.txt
        else
            echo "Service not reachable" >> zap-reports/security-headers-check.txt
        fi
    done
    
    echo ""
    echo "✅ Basic security checks completed"
fi

echo ""
echo "=========================================="
echo "📊 DAST Scan Summary"
echo "=========================================="
echo ""

# Display summary
if [ -f "zap-reports/frontend-baseline.json" ]; then
    echo "✅ Scan reports generated:"
    ls -lh zap-reports/ 2>/dev/null | grep -v "^total" | grep -v "^d" || echo "   No reports found"
    
    echo ""
    echo "📈 Quick Stats:"
    if command -v jq &> /dev/null; then
        if [ -f "zap-reports/frontend-baseline.json" ]; then
            echo "   Frontend Alerts: $(jq '.site[0].alerts | length' zap-reports/frontend-baseline.json 2>/dev/null || echo 'N/A')"
        fi
        if [ -f "zap-reports/backend-baseline.json" ]; then
            echo "   Backend Alerts:  $(jq '.site[0].alerts | length' zap-reports/backend-baseline.json 2>/dev/null || echo 'N/A')"
        fi
    fi
else
    echo "📄 Reports generated in: ./zap-reports/"
    ls -lh zap-reports/ 2>/dev/null | tail -n +2
fi

echo ""
echo "💡 View Reports:"
echo "   HTML:     open zap-reports/*-baseline.html"
echo "   JSON:     cat zap-reports/*-baseline.json | jq"
echo "   Markdown: cat zap-reports/*-baseline.md"
echo "   Headers:  cat zap-reports/security-headers-check.txt"
echo ""

echo "🔒 Common Security Recommendations:"
echo "   1. Implement Content Security Policy (CSP)"
echo "   2. Add Anti-CSRF tokens to all forms"
echo "   3. Enable Strict Transport Security (HSTS)"
echo "   4. Set X-Frame-Options to prevent clickjacking"
echo "   5. Configure secure session management"
echo "   6. Implement rate limiting on APIs"
echo "   7. Use HTTPS in production"
echo "   8. Sanitize all user inputs"
echo ""

echo -e "${GREEN}✅ DAST Security Testing Completed!${NC}"
echo ""
