#!/bin/bash

# Script pour nettoyer et reconstruire le backend
# Corrige les problèmes d'architecture avec bcrypt

echo "🧹 Nettoyage et reconstruction du backend..."

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Arrêter les conteneurs
print_message "Arrêt des conteneurs..."
docker-compose down 2>/dev/null || true

# Supprimer l'image backend
print_message "Suppression de l'ancienne image backend..."
docker rmi food-delivery-backend 2>/dev/null || true

# Nettoyer node_modules sur l'hôte
print_message "Nettoyage des node_modules sur l'hôte..."
rm -rf backend/node_modules
rm -rf frontend/node_modules  
rm -rf admin/node_modules

# Nettoyer le cache Docker
print_message "Nettoyage du cache Docker..."
docker builder prune -f

# Reconstruire uniquement le backend
print_message "Reconstruction du backend avec correction bcrypt..."
docker-compose build --no-cache backend

if [ $? -eq 0 ]; then
    print_success "Backend reconstruit avec succès !"
    
    # Relancer tous les services
    print_message "Démarrage de tous les services..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        print_success "🎉 Application démarrée avec succès !"
        echo ""
        print_message "URLs disponibles :"
        echo "  📱 Frontend: http://localhost:3000"
        echo "  🛠️  Admin:    http://localhost:3001"
        echo "  🔧 Backend:  http://localhost:4000"
        echo ""
        print_message "Vérifiez les logs avec: docker-compose logs -f backend"
    else
        print_error "Échec du démarrage des services"
        exit 1
    fi
else
    print_error "Échec de la reconstruction du backend"
    exit 1
fi