#!/bin/bash

# Script tout-en-un pour construire et lancer l'application
# Usage: ./start.sh

echo "🚀 Démarrage complet de l'application Food Delivery..."

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

# Vérifier si Docker est installé et en cours d'exécution
if ! command -v docker &> /dev/null; then
    print_error "Docker n'est pas installé. Veuillez installer Docker d'abord."
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker n'est pas en cours d'exécution. Veuillez démarrer Docker."
    exit 1
fi

print_success "Docker est disponible et en cours d'exécution ✅"

# Vérifier et démarrer SonarQube
print_message "🔍 Vérification de SonarQube..."
if docker ps --format '{{.Names}}' | grep -q '^sonarqube$'; then
    print_success "SonarQube est déjà en cours d'exécution"
else
    if docker ps -a --format '{{.Names}}' | grep -q '^sonarqube$'; then
        print_message "Démarrage de SonarQube existant..."
        docker start sonarqube
        print_success "SonarQube démarré"
    else
        print_warning "SonarQube n'est pas configuré. Exécutez ./setup-jenkins.sh pour le configurer"
    fi
fi

# Vérifier et démarrer Jenkins
print_message "🔧 Vérification de Jenkins..."
if docker ps --format '{{.Names}}' | grep -q '^jenkins$'; then
    print_success "Jenkins est déjà en cours d'exécution"
else
    if docker ps -a --format '{{.Names}}' | grep -q '^jenkins$'; then
        print_message "Démarrage de Jenkins existant..."
        docker start jenkins
        print_success "Jenkins démarré"
    else
        print_warning "Jenkins n'est pas configuré. Exécutez ./setup-jenkins.sh pour le configurer"
    fi
fi

# Vérifier et démarrer le monitoring
print_message "📊 Vérification du monitoring..."
if docker ps --format '{{.Names}}' | grep -q '^prometheus$'; then
    print_success "Monitoring déjà en cours d'exécution"
else
    if docker ps -a --format '{{.Names}}' | grep -q '^prometheus$'; then
        print_message "Démarrage du monitoring..."
        docker-compose -f docker-compose.monitoring.yml start 2>/dev/null || print_warning "Monitoring non configuré"
    else
        print_warning "Monitoring non configuré. Exécutez ./start-monitoring.sh"
    fi
fi

echo ""

# Étape 1: Construire les images
print_message "🔨 Étape 1: Construction des images..."
if ./build.sh; then
    print_success "Construction terminée avec succès"
else
    print_error "Échec de la construction"
    exit 1
fi

echo ""

# Étape 2: Lancer les conteneurs
print_message "🏃 Étape 2: Lancement des conteneurs..."
if ./run.sh; then
    print_success "Lancement terminé avec succès"
else
    print_error "Échec du lancement"
    exit 1
fi

echo ""
print_success "🎉 Application Food Delivery prête !"
echo ""
print_message "📝 Commandes utiles :"
echo "  ./logs.sh          - Voir les logs"
echo "  ./stop.sh          - Arrêter l'application"
echo "  ./build.sh         - Reconstruire les images"
echo "  ./run.sh           - Relancer les conteneurs"
echo ""
print_message "🌐 URLs de l'application :"
echo "  📱 Frontend: http://localhost:3000"
echo "  🛠️  Admin:    http://localhost:3001"
echo "  🔧 Backend:  http://localhost:4000"
echo "  🔐 Jenkins:  http://localhost:8080"
echo "  📊 SonarQube: http://localhost:9000"