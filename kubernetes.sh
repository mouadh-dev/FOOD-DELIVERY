#!/bin/bash

set -e  # Arrêter le script en cas d'erreur

echo "🚀 Démarrage de l'installation et configuration du cluster Kubernetes..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Étape 1: Vérifier les prérequis
log_info "Vérification des prérequis..."

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier kubectl
if ! command -v kubectl &> /dev/null; then
    log_warning "kubectl n'est pas installé. Installation..."
    brew install kubectl
fi

# Vérifier kind
if ! command -v kind &> /dev/null; then
    log_warning "kind n'est pas installé. Installation..."
    brew install kind
fi

log_info "Tous les prérequis sont satisfaits ✅"

# Étape 2: Créer le fichier de configuration Kind (si il n'existe pas)
if [ ! -f "kind.yaml" ]; then
    log_info "Création du fichier de configuration kind.yaml..."
    cat > kind.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
networking:
  podSubnet: "10.244.0.0/16"
EOF
    log_info "Fichier kind.yaml créé ✅"
fi

# Étape 3: Supprimer le cluster existant s'il existe
CLUSTER_NAME="food-delivery-cluster"
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    log_warning "Suppression du cluster existant..."
    kind delete cluster --name=$CLUSTER_NAME
fi

# Étape 4: Créer le cluster Kubernetes
log_info "Création du cluster Kubernetes avec Kind..."
kind create cluster --config=kind.yaml --name=$CLUSTER_NAME

# Attendre que le cluster soit prêt
log_info "Attente que le cluster soit prêt..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Étape 5: Vérifier l'état initial du cluster
log_info "Vérification de l'état initial du cluster..."
echo "Nodes disponibles:"
kubectl get nodes

# Étape 6: Installer le réseau overlay (Flannel)
log_info "Installation du réseau overlay Flannel..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Attendre que les pods Flannel soient prêts
log_info "Attente que les pods Flannel soient prêts..."
kubectl wait --for=condition=Ready pods -l app=flannel -n kube-flannel --timeout=300s

# Étape 7: Vérifier l'état final du cluster
log_info "Vérification finale du cluster..."
echo ""
echo "=== État du cluster ==="
kubectl cluster-info
echo ""
echo "=== Nodes du cluster ==="
kubectl get nodes -o wide
echo ""
echo "=== Pods système ==="
kubectl get pods -A
echo ""

# Étape 8: Test de fonctionnalité
log_info "Test de fonctionnalité du cluster..."
kubectl create deployment test-nginx --image=nginx --replicas=2
kubectl wait --for=condition=Available deployment/test-nginx --timeout=120s

echo ""
echo "=== Test de déploiement ==="
kubectl get deployment test-nginx
kubectl get pods -l app=test-nginx

# Nettoyage du test
kubectl delete deployment test-nginx

echo ""
log_info "🎉 Cluster Kubernetes configuré avec succès!"
echo ""
echo "Pour utiliser votre cluster:"
echo "  kubectl get nodes"
echo "  kubectl get pods -A"
echo ""
echo "Pour supprimer le cluster:"
echo "  kind delete cluster --name=$CLUSTER_NAME"