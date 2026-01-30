#!/bin/bash

# Stop Monitoring Stack Script

echo "🛑 Stopping Monitoring Stack..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Stop monitoring services
docker-compose -f docker-compose.monitoring.yml down

print_success "Monitoring stack stopped successfully!"
echo ""
print_message "To start again: ./start-monitoring.sh"
