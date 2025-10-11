#!/bin/bash

# Script pour voir les logs des conteneurs
# Usage: ./logs.sh [service]
# Exemples: ./logs.sh backend, ./logs.sh frontend, ./logs.sh admin, ./logs.sh (tous)

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

# Fonction pour afficher les logs d'un conteneur
show_logs() {
    local service=$1
    local container_name="food-delivery-${service}-container"
    
    if docker ps | grep -q "$container_name"; then
        print_message "Logs du $service :"
        echo "----------------------------------------"
        docker logs --tail=50 "$container_name"
        echo "----------------------------------------"
        echo ""
    else
        print_warning "Le conteneur $service n'est pas en cours d'exécution"
    fi
}

# Vérifier l'argument
service=${1:-"all"}

case $service in
    "backend")
        show_logs "backend"
        ;;
    "frontend")
        show_logs "frontend"
        ;;
    "admin")
        show_logs "admin"
        ;;
    "all"|"")
        print_message "📋 Affichage des logs de tous les services..."
        echo ""
        show_logs "backend"
        show_logs "frontend"
        show_logs "admin"
        ;;
    *)
        print_error "Service inconnu: $service"
        echo "Usage: $0 [backend|frontend|admin|all]"
        exit 1
        ;;
esac

print_message "Pour suivre les logs en temps réel :"
echo "  docker logs -f food-delivery-backend-container"
echo "  docker logs -f food-delivery-frontend-container"
echo "  docker logs -f food-delivery-admin-container"