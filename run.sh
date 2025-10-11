#!/bin/bash

# Script pour lancer tous les conteneurs
# Usage: ./run.sh

echo "🚀 Lancement de l'application Food Delivery..."

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Vérifier si les images existent
check_image() {
    if ! docker images | grep -q "$1"; then
        print_error "Image $1 non trouvée. Veuillez d'abord exécuter ./build.sh"
        exit 1
    fi
}

print_message "Vérification des images..."
check_image "food-delivery-backend"
check_image "food-delivery-frontend"
check_image "food-delivery-admin"

# Arrêter les conteneurs existants s'ils tournent
print_message "Arrêt des conteneurs existants..."
docker stop food-delivery-backend-container 2>/dev/null || true
docker stop food-delivery-frontend-container 2>/dev/null || true
docker stop food-delivery-admin-container 2>/dev/null || true

# Supprimer les conteneurs existants
docker rm food-delivery-backend-container 2>/dev/null || true
docker rm food-delivery-frontend-container 2>/dev/null || true
docker rm food-delivery-admin-container 2>/dev/null || true

# Lancer le backend
print_message "Lancement du backend sur le port 4000..."
if docker run -d --name food-delivery-backend-container -p 4000:4000 food-delivery-backend; then
    print_success "Backend démarré avec succès"
else
    print_error "Échec du démarrage du backend"
    exit 1
fi

# Attendre un peu que le backend démarre
sleep 2

# Lancer le frontend
print_message "Lancement du frontend sur le port 3000..."
if docker run -d --name food-delivery-frontend-container -p 3000:80 food-delivery-frontend; then
    print_success "Frontend démarré avec succès"
else
    print_error "Échec du démarrage du frontend"
    exit 1
fi

# Lancer l'admin
print_message "Lancement de l'admin sur le port 3001..."
if docker run -d --name food-delivery-admin-container -p 3001:80 food-delivery-admin; then
    print_success "Admin démarré avec succès"
else
    print_error "Échec du démarrage de l'admin"
    exit 1
fi

print_success "🎉 Application Food Delivery lancée avec succès !"
echo ""
print_message "URLs de l'application :"
echo "  📱 Frontend: http://localhost:3000"
echo "  🛠️  Admin:    http://localhost:3001"
echo "  🔧 Backend:  http://localhost:4000"
echo ""
print_message "Pour voir les logs : ./logs.sh"
print_message "Pour arrêter : ./stop.sh"