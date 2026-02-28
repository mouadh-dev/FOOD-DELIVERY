#!/bin/bash

# Script to test Dependency Analysis (npm audit) locally
# This simulates the Jenkins Dependency Check stage

set -e

echo "=========================================="
echo "🛡️ Dependency Analysis Test"
echo "=========================================="
echo ""

# Create reports directory
mkdir -p dependency-reports

# Function to run npm audit
run_audit() {
    local component=$1
    local dir=$2
    
    echo "📦 Analyzing ${component} dependencies..."
    echo "-------------------------------------------"
    
    cd "$dir"
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "⚠️  node_modules not found. Installing dependencies..."
        npm ci
    fi
    
    # Run npm audit
    echo ""
    echo "Running npm audit for ${component}..."
    npm audit --audit-level=moderate --json > "../dependency-reports/npm-audit-${component}.json" || true
    
    # Display summary
    echo ""
    if [ -f "../dependency-reports/npm-audit-${component}.json" ]; then
        echo "📊 ${component} Audit Summary:"
        cat "../dependency-reports/npm-audit-${component}.json" | jq -r '
            if .metadata then
                "   Total Dependencies: \(.metadata.dependencies // "N/A")
   Vulnerabilities:
      - Critical: \(.metadata.vulnerabilities.critical // 0)
      - High:     \(.metadata.vulnerabilities.high // 0)
      - Moderate: \(.metadata.vulnerabilities.moderate // 0)
      - Low:      \(.metadata.vulnerabilities.low // 0)
      - Info:     \(.metadata.vulnerabilities.info // 0)"
            else
                "   ⚠️  No metadata found in audit report"
            end
        ' 2>/dev/null || echo "   ⚠️  Unable to parse audit results"
    fi
    
    echo ""
    echo "✅ ${component} audit completed"
    echo ""
    
    cd ..
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq is not installed. Installing with brew..."
    brew install jq || echo "❌ Failed to install jq. Please install manually: brew install jq"
fi

# Run audits for all components
run_audit "backend" "backend"
run_audit "frontend" "frontend"
run_audit "admin" "admin"

echo "=========================================="
echo "✅ Dependency Analysis Completed!"
echo "=========================================="
echo ""
echo "📊 Reports saved in: ./dependency-reports/"
echo ""
echo "📁 Generated reports:"
ls -lh dependency-reports/ 2>/dev/null || echo "   No reports found"
echo ""
echo "💡 To view detailed report:"
echo "   cat dependency-reports/npm-audit-backend.json | jq"
echo "   cat dependency-reports/npm-audit-frontend.json | jq"
echo "   cat dependency-reports/npm-audit-admin.json | jq"
echo ""
echo "💡 To view vulnerabilities only:"
echo "   cat dependency-reports/npm-audit-backend.json | jq '.vulnerabilities'"
echo ""
