#!/bin/bash

# Script pour construire toutes les images Docker
# Usage: ./build.sh

echo "🚀 Construction des images Docker pour Food Delivery..."

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Construction du backend
print_message "Construction de l'image backend..."
cd backend
if docker build -t food-delivery-backend .; then
    print_success "Image backend construite avec succès"
else
    print_error "Échec de la construction du backend"
    exit 1
fi
cd ..

# Construction du frontend
print_message "Construction de l'image frontend..."
cd frontend
if docker build -t food-delivery-frontend .; then
    print_success "Image frontend construite avec succès"
else
    print_error "Échec de la construction du frontend"
    exit 1
fi
cd ..

# Construction de l'admin
print_message "Construction de l'image admin..."
cd admin
if docker build -t food-delivery-admin .; then
    print_success "Image admin construite avec succès"
else
    print_error "Échec de la construction de l'admin"
    exit 1
fi
cd ..

print_success "Toutes les images ont été construites avec succès ! 🎉"

# Afficher les images créées
print_message "Images Docker créées :"
docker images | grep food-delivery