#!/bin/bash

# Script Docker Compose pour Food Delivery
# Usage: ./docker-compose.sh [commande]

# Couleurs pour les messages
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

# Fonction d'aide
show_help() {
    echo "🐳 Script Docker Compose pour Food Delivery"
    echo ""
    echo "Usage: $0 [COMMANDE]"
    echo ""
    echo "Commandes disponibles:"
    echo "  up          Démarrer tous les services"
    echo "  down        Arrêter tous les services"
    echo "  build       Construire toutes les images"
    echo "  rebuild     Reconstruire et redémarrer"
    echo "  logs        Afficher les logs"
    echo "  status      Voir l'état des services"
    echo "  clean       Nettoyer les ressources"
    echo "  help        Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 up       # Démarrer l'application"
    echo "  $0 logs     # Voir les logs"
    echo "  $0 down     # Arrêter l'application"
}

# Vérifier si Docker Compose est installé
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose n'est pas installé"
        exit 1
    fi
}

# Commande docker-compose (gère les deux versions)
docker_compose_cmd() {
    if command -v docker-compose &> /dev/null; then
        docker-compose "$@"
    else
        docker compose "$@"
    fi
}

# Traitement des commandes
case ${1:-help} in
    "up"|"start")
        check_docker_compose
        print_message "🚀 Démarrage de l'application Food Delivery..."
        docker_compose_cmd up -d
        print_success "Application démarrée ! 🎉"
        echo ""
        print_message "🌐 URLs disponibles :"
        echo "  📱 Frontend: http://localhost:3000"
        echo "  🛠️  Admin:    http://localhost:3001"
        echo "  🔧 Backend:  http://localhost:4000"
        echo "  🗄️  MongoDB:  mongodb://localhost:27017"
        ;;
    
    "down"|"stop")
        check_docker_compose
        print_message "🛑 Arrêt de l'application..."
        docker_compose_cmd down
        print_success "Application arrêtée"
        ;;
    
    "build")
        check_docker_compose
        print_message "🔨 Construction des images..."
        docker_compose_cmd build
        print_success "Images construites"
        ;;
    
    "rebuild")
        check_docker_compose
        print_message "🔄 Reconstruction et redémarrage..."
        docker_compose_cmd down
        docker_compose_cmd build --no-cache
        docker_compose_cmd up -d
        print_success "Application reconstruite et redémarrée"
        ;;
    
    "logs")
        check_docker_compose
        print_message "📋 Affichage des logs..."
        docker_compose_cmd logs -f
        ;;
    
    "status"|"ps")
        check_docker_compose
        print_message "📊 État des services :"
        docker_compose_cmd ps
        ;;
    
    "clean")
        check_docker_compose
        print_warning "⚠️  Cela va supprimer tous les conteneurs et volumes"
        read -p "Êtes-vous sûr ? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_message "🧹 Nettoyage en cours..."
            docker_compose_cmd down -v --rmi all
            print_success "Nettoyage terminé"
        else
            print_message "Nettoyage annulé"
        fi
        ;;
    
    "help"|*)
        show_help
        ;;
esac