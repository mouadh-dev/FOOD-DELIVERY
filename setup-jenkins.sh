#!/bin/bash

# Script d'installation et configuration Jenkins pour Food Delivery
# Ce script configure l'environnement complet : Jenkins, SonarQube, et réseaux Docker

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Vérifier si Docker est en cours d'exécution
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker n'est pas en cours d'exécution. Veuillez démarrer Docker Desktop."
        exit 1
    fi
    print_success "Docker est en cours d'exécution"
}

# Créer les réseaux Docker
create_networks() {
    print_header "Création des réseaux Docker"
    
    if docker network inspect food-delivery-network > /dev/null 2>&1; then
        print_info "Le réseau 'food-delivery-network' existe déjà"
    else
        docker network create food-delivery-network
        print_success "Réseau 'food-delivery-network' créé"
    fi
}

# Nettoyer les conteneurs existants en conflit
cleanup_containers() {
    print_header "Nettoyage des conteneurs en conflit"
    
    # Arrêter et supprimer SonarQube s'il existe
    if docker ps -a --format '{{.Names}}' | grep -q '^sonarqube$'; then
        print_info "Suppression du conteneur SonarQube existant..."
        docker stop sonarqube 2>/dev/null || true
        docker rm sonarqube 2>/dev/null || true
        print_success "Conteneur SonarQube supprimé"
    fi
}

# Démarrer Jenkins
start_jenkins() {
    print_header "Démarrage de Jenkins"
    
    cd jenkins
    
    # Mettre à jour le docker-compose.yml de Jenkins
    cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  jenkins:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: jenkins
    privileged: true
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - ../:/workspace
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock
      - DOCKER_REGISTRY=localhost
      - IMAGE_NAME=food-delivery
    networks:
      - default
      - food-delivery-network
    restart: unless-stopped

networks:
  food-delivery-network:
    external: true
  default:
    driver: bridge

volumes:
  jenkins_home:
    driver: local
EOF
    
    print_info "Construction et démarrage de Jenkins..."
    docker-compose up -d --build
    
    print_success "Jenkins est en cours de démarrage..."
    cd ..
}

# Démarrer SonarQube
start_sonarqube() {
    print_header "Démarrage de SonarQube"
    
    print_info "Démarrage du conteneur SonarQube..."
    docker run -d \
        --name sonarqube \
        -p 9000:9000 \
        --network food-delivery-network \
        -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
        -v sonarqube_data:/opt/sonarqube/data \
        -v sonarqube_logs:/opt/sonarqube/logs \
        -v sonarqube_extensions:/opt/sonarqube/extensions \
        sonarqube:lts-community
    
    print_success "SonarQube est en cours de démarrage..."
}

# Attendre que les services soient prêts
wait_for_services() {
    print_header "Attente du démarrage des services"
    
    print_info "Attente de Jenkins (peut prendre 1-2 minutes)..."
    sleep 30
    
    # Attendre Jenkins
    RETRY=0
    MAX_RETRY=30
    while [ $RETRY -lt $MAX_RETRY ]; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            print_success "Jenkins est prêt"
            break
        fi
        RETRY=$((RETRY + 1))
        sleep 2
    done
    
    # Attendre SonarQube
    print_info "Attente de SonarQube (peut prendre 2-3 minutes)..."
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        if curl -s http://localhost:9000 > /dev/null 2>&1; then
            print_success "SonarQube est prêt"
            break
        fi
        RETRY=$((RETRY + 1))
        sleep 4
    done
}

# Afficher les informations de connexion
show_info() {
    print_header "🎉 Installation terminée avec succès!"
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           INFORMATIONS DE CONNEXION                       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Mot de passe Jenkins
    echo -e "${BLUE}📦 Jenkins:${NC}"
    echo -e "   URL: ${YELLOW}http://localhost:8080${NC}"
    if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        JENKINS_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
        echo -e "   Mot de passe initial: ${YELLOW}${JENKINS_PASSWORD}${NC}"
    else
        echo -e "   ${RED}Mot de passe initial non disponible (Jenkins en cours de démarrage)${NC}"
        echo -e "   ${BLUE}Exécutez: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword${NC}"
    fi
    
    echo -e "\n${BLUE}🔍 SonarQube:${NC}"
    echo -e "   URL: ${YELLOW}http://localhost:9000${NC}"
    echo -e "   Login: ${YELLOW}admin${NC}"
    echo -e "   Password: ${YELLOW}admin${NC}"
    echo -e "   ${RED}⚠️  Changez le mot de passe à la première connexion${NC}"
    
    echo -e "\n${BLUE}📋 Commandes utiles:${NC}"
    echo -e "   Arrêter tout: ${YELLOW}docker-compose -f jenkins/docker-compose.yml down && docker stop sonarqube${NC}"
    echo -e "   Logs Jenkins: ${YELLOW}docker logs -f jenkins${NC}"
    echo -e "   Logs SonarQube: ${YELLOW}docker logs -f sonarqube${NC}"
    echo -e "   Redémarrer Jenkins: ${YELLOW}cd jenkins && docker-compose restart${NC}"
    
    echo -e "\n${BLUE}🚀 Prochaines étapes:${NC}"
    echo -e "   1. Connectez-vous à Jenkins: ${YELLOW}http://localhost:8080${NC}"
    echo -e "   2. Installez les plugins suggérés"
    echo -e "   3. Connectez-vous à SonarQube: ${YELLOW}http://localhost:9000${NC}"
    echo -e "   4. Créez un token SonarQube: My Account > Security > Generate Token"
    echo -e "   5. Configurez SonarQube dans Jenkins: Manage Jenkins > Configure System > SonarQube servers"
    echo -e "   6. Créez un nouveau job Pipeline dans Jenkins"
    echo -e "   7. Pointez le job vers le Jenkinsfile dans le repository\n"
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Environnement Jenkins + SonarQube prêt! 🎉              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

# Main
main() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     Food Delivery - Installation Jenkins & SonarQube    ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    check_docker
    create_networks
    cleanup_containers
    start_jenkins
    start_sonarqube
    wait_for_services
    show_info
}

# Gestion des erreurs
trap 'print_error "Une erreur est survenue. Installation interrompue."; exit 1' ERR

main
