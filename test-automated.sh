#!/bin/bash

# Script to run automated tests for all components
# This simulates the Jenkins Test stage

set -e

echo "=========================================="
echo "🧪 Running Automated Tests"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create test reports directory
mkdir -p test-reports

# Function to run tests
run_tests() {
    local component=$1
    local dir=$2
    local test_cmd=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Testing ${component}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "$dir"
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "⚠️  node_modules not found. Installing dependencies..."
        npm ci --quiet
    fi
    
    # Check if test dependencies are installed
    echo "📥 Installing test dependencies..."
    npm install --quiet --save-dev 2>/dev/null || true
    
    # Run tests
    echo ""
    echo "🏃 Running tests for ${component}..."
    if eval "$test_cmd"; then
        echo -e "${GREEN}✅ ${component} tests PASSED${NC}"
        echo "PASS" > "../test-reports/${component}-status.txt"
    else
        echo -e "${RED}❌ ${component} tests FAILED${NC}"
        echo "FAIL" > "../test-reports/${component}-status.txt"
    fi
    
    # Copy coverage reports if they exist
    if [ -d "coverage" ]; then
        echo "📊 Copying coverage reports..."
        cp -r coverage "../test-reports/${component}-coverage" 2>/dev/null || true
    fi
    
    echo ""
    cd ..
}

# Install testing tools if not present
echo "🔧 Checking testing tools..."
echo ""

# Run tests for all components
run_tests "Backend" "backend" "npm test -- --passWithNoTests"
run_tests "Frontend" "frontend" "npm test -- --run"
run_tests "Admin" "admin" "npm test -- --run"

echo "=========================================="
echo "📊 Test Summary"
echo "=========================================="
echo ""

# Display results
BACKEND_STATUS=$(cat test-reports/Backend-status.txt 2>/dev/null || echo "UNKNOWN")
FRONTEND_STATUS=$(cat test-reports/Frontend-status.txt 2>/dev/null || echo "UNKNOWN")
ADMIN_STATUS=$(cat test-reports/Admin-status.txt 2>/dev/null || echo "UNKNOWN")

echo "Test Results:"
if [ "$BACKEND_STATUS" = "PASS" ]; then
    echo -e "  Backend:  ${GREEN}✅ PASSED${NC}"
else
    echo -e "  Backend:  ${RED}❌ FAILED${NC}"
fi

if [ "$FRONTEND_STATUS" = "PASS" ]; then
    echo -e "  Frontend: ${GREEN}✅ PASSED${NC}"
else
    echo -e "  Frontend: ${RED}❌ FAILED${NC}"
fi

if [ "$ADMIN_STATUS" = "PASS" ]; then
    echo -e "  Admin:    ${GREEN}✅ PASSED${NC}"
else
    echo -e "  Admin:    ${RED}❌ FAILED${NC}"
fi

echo ""
echo "📁 Test reports saved in: ./test-reports/"
ls -lh test-reports/ 2>/dev/null | grep -v "^total" | grep -v "^d" || echo "   No reports found"

echo ""
echo "💡 View coverage reports:"
echo "   open test-reports/Backend-coverage/index.html"
echo "   open test-reports/Frontend-coverage/index.html"
echo "   open test-reports/Admin-coverage/index.html"
echo ""

# Exit with error if any tests failed
if [ "$BACKEND_STATUS" = "FAIL" ] || [ "$FRONTEND_STATUS" = "FAIL" ] || [ "$ADMIN_STATUS" = "FAIL" ]; then
    echo -e "${RED}❌ Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
fi
