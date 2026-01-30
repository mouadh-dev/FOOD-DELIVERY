#!/bin/bash

# Script pour arrêter tous les conteneurs
# Usage: ./stop.sh

echo "🛑 Arrêt de l'application Food Delivery..."

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

# Arrêter et supprimer les conteneurs
containers=("food-delivery-backend-container" "food-delivery-frontend-container" "food-delivery-admin-container")

for container in "${containers[@]}"; do
    if docker ps | grep -q "$container"; then
        print_message "Arrêt du conteneur $container..."
        docker stop "$container"
        print_success "Conteneur $container arrêté"
    else
        print_message "Conteneur $container n'est pas en cours d'exécution"
    fi
    
    # Supprimer le conteneur
    if docker ps -a | grep -q "$container"; then
        print_message "Suppression du conteneur $container..."
        docker rm "$container"
        print_success "Conteneur $container supprimé"
    fi
done

# Arrêter Jenkins et SonarQube (sans les supprimer)
print_message "Arrêt de Jenkins et SonarQube..."
docker stop jenkins sonarqube 2>/dev/null || true
print_success "Jenkins et SonarQube arrêtés"

print_success "🎉 Tous les conteneurs d'application ont été arrêtés !"

# Afficher les conteneurs restants
print_message "Conteneurs Docker restants :"
docker ps -a