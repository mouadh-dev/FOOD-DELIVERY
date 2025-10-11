#!/bin/bash

# Script pour nettoyer les ressources Docker
# Usage: ./clean.sh

echo "🧹 Nettoyage des ressources Docker..."

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

# Arrêter tous les conteneurs d'abord
print_message "Arrêt des conteneurs..."
./stop.sh

echo ""

# Supprimer les images Food Delivery
print_message "Suppression des images Food Delivery..."
images=("food-delivery-backend" "food-delivery-frontend" "food-delivery-admin")

for image in "${images[@]}"; do
    if docker images | grep -q "$image"; then
        print_message "Suppression de l'image $image..."
        docker rmi "$image"
        print_success "Image $image supprimée"
    else
        print_message "Image $image non trouvée"
    fi
done

# Nettoyer les ressources inutilisées (optionnel)
read -p "Voulez-vous nettoyer toutes les ressources Docker inutilisées ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_message "Nettoyage des ressources inutilisées..."
    docker system prune -f
    print_success "Nettoyage terminé"
fi

print_success "🎉 Nettoyage terminé !"

# Afficher l'état final
print_message "État final des images Docker :"
docker images | head -5