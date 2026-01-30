#!/bin/bash

# Start Monitoring Stack Script

echo "🚀 Starting Monitoring Stack for Food Delivery..."

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker is running
if ! docker info &> /dev/null; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Create network if it doesn't exist
print_message "Checking Docker network..."
if ! docker network ls | grep -q food-delivery-network; then
    print_message "Creating food-delivery-network..."
    docker network create food-delivery-network
    print_success "Network created"
else
    print_success "Network already exists"
fi

# Start monitoring stack
print_message "Starting monitoring services..."
docker-compose -f docker-compose.monitoring.yml up -d

# Wait for services to start
print_message "Waiting for services to start (30 seconds)..."
sleep 30

# Check service status
echo ""
print_message "📊 Monitoring Stack Status:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Prometheus
if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    print_success "Prometheus: Running ✅"
else
    print_warning "Prometheus: Starting... ⏳"
fi

# Grafana
if curl -s http://localhost:3002/api/health > /dev/null 2>&1; then
    print_success "Grafana: Running ✅"
else
    print_warning "Grafana: Starting... ⏳"
fi

# Alertmanager
if curl -s http://localhost:9093/-/healthy > /dev/null 2>&1; then
    print_success "Alertmanager: Running ✅"
else
    print_warning "Alertmanager: Starting... ⏳"
fi

# Node Exporter
if curl -s http://localhost:9100/metrics > /dev/null 2>&1; then
    print_success "Node Exporter: Running ✅"
else
    print_warning "Node Exporter: Starting... ⏳"
fi

# cAdvisor
if curl -s http://localhost:8081/healthz > /dev/null 2>&1; then
    print_success "cAdvisor: Running ✅"
else
    print_warning "cAdvisor: Starting... ⏳"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "🎉 Monitoring stack started successfully!"
echo ""
print_message "📊 Access URLs:"
echo "  🎯 Prometheus:    http://localhost:9090"
echo "  📈 Grafana:       http://localhost:3002 (admin/admin)"
echo "  🔔 Alertmanager:  http://localhost:9093"
echo "  📊 Node Exporter: http://localhost:9100/metrics"
echo "  🐳 cAdvisor:      http://localhost:8081"
echo ""
print_message "🔧 Useful commands:"
echo "  View logs:     docker-compose -f docker-compose.monitoring.yml logs -f"
echo "  Stop:          docker-compose -f docker-compose.monitoring.yml down"
echo "  Restart:       docker-compose -f docker-compose.monitoring.yml restart"
echo ""
print_warning "⚠️  Configure alertmanager.yml with your email/Slack settings for alerts"
echo ""
