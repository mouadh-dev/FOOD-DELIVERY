#!/bin/bash

# Script de test pour vérifier que l'application fonctionne
# Usage: ./test-app.sh

echo "🧪 Test de l'application Food Delivery..."

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Attendre que les services soient prêts
wait_for_service() {
    local url=$1
    local service=$2
    local max_attempts=30
    local attempt=1

    print_test "Attente du service $service..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            print_success "$service est prêt"
            return 0
        fi
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    print_error "$service n'est pas accessible après $max_attempts tentatives"
    return 1
}

# Tests des services
echo "🔍 Vérification des services..."

# Test Backend
if wait_for_service "http://localhost:4000" "Backend API"; then
    # Test d'une route spécifique si elle existe
    print_test "Test de l'API Backend..."
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4000)
    if [ "$response" -eq 200 ] || [ "$response" -eq 404 ]; then
        print_success "Backend répond (Code: $response)"
    else
        print_error "Backend ne répond pas correctement (Code: $response)"
    fi
fi

# Test Frontend
if wait_for_service "http://localhost:3000" "Frontend"; then
    print_success "Frontend accessible"
fi

# Test Admin
if wait_for_service "http://localhost:3001" "Admin Panel"; then
    print_success "Admin Panel accessible"
fi

# Test MongoDB
print_test "Test de MongoDB..."
if nc -z localhost 27017 2>/dev/null; then
    print_success "MongoDB accessible sur le port 27017"
else
    print_error "MongoDB non accessible"
fi

echo ""
print_success "🎉 Tests terminés !"
echo ""
echo "📊 Résumé des services :"
echo "  Frontend:  http://localhost:3000"
echo "  Admin:     http://localhost:3001"
echo "  Backend:   http://localhost:4000"
echo "  MongoDB:   mongodb://localhost:27017"