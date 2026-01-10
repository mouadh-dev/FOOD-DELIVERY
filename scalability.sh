#!/bin/bash

set -e  # Arrêter le script en cas d'erreur

echo "🚀 Configuration de la Scalabilité Horizontale des Pods Kubernetes..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Fonction pour attendre que les pods soient prêts
wait_for_pods() {
    local label=$1
    local timeout=${2:-120}
    
    log_info "Attente que les pods avec label '$label' soient prêts..."
    kubectl wait --for=condition=Ready pods -l $label --timeout=${timeout}s
    
    if [ $? -eq 0 ]; then
        log_info "✅ Pods prêts"
    else
        log_error "❌ Timeout en attendant les pods"
        return 1
    fi
}

# Étape 1: Vérifier les prérequis
log_step "1. Vérification des prérequis..."

# Vérifier que le cluster est accessible
if ! kubectl cluster-info &>/dev/null; then
    log_error "Cluster Kubernetes non accessible"
    exit 1
fi

# Vérifier que le déploiement backend existe
if ! kubectl get deployment backend-deployment &>/dev/null; then
    log_error "Le déploiement 'backend-deployment' n'existe pas"
    exit 1
fi

log_info "Tous les prérequis sont satisfaits ✅"

# Étape 2: Installer metrics-server
log_step "2. Installation du metrics-server..."

# Vérifier si metrics-server est déjà installé
if kubectl get deployment metrics-server -n kube-system &>/dev/null; then
    log_warning "metrics-server déjà installé"
else
    log_info "Installation du metrics-server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Patcher metrics-server pour Kind
    log_info "Configuration du metrics-server pour Kind..."
    kubectl patch -n kube-system deployment metrics-server --type='json' -p='[
      {
        "op": "add",
        "path": "/spec/template/spec/containers/0/args/-",
        "value": "--kubelet-insecure-tls"
      },
      {
        "op": "add", 
        "path": "/spec/template/spec/containers/0/args/-",
        "value": "--kubelet-preferred-address-types=InternalIP"
      }
    ]'
fi

# Attendre que metrics-server soit prêt
log_info "Attente que metrics-server soit prêt..."
kubectl wait --for=condition=Available deployment/metrics-server -n kube-system --timeout=120s

# Vérifier que les métriques sont disponibles
log_info "Vérification des métriques..."
sleep 30  # Attendre que les métriques soient collectées

# Étape 3: Tâche 19 - HPA basé sur CPU
log_step "3. Tâche 19 - Configuration HPA basé sur CPU (70%, min=2, max=4)..."

# Supprimer l'ancien HPA s'il existe
kubectl delete hpa backend-deployment --ignore-not-found=true

# Créer HPA basé sur CPU
kubectl autoscale deployment backend-deployment --cpu-percent=70 --min=2 --max=4

log_info "HPA CPU créé avec succès"

# Vérifier le HPA
kubectl get hpa backend-deployment

# Attendre un moment pour voir les métriques
log_info "Attente de la collecte des métriques CPU..."
sleep 20

log_info "État du HPA basé sur CPU:"
kubectl describe hpa backend-deployment

# Étape 4: Tâche 20 - HPA basé sur RAM
log_step "4. Tâche 20 - Reconfiguration HPA basé sur RAM (75%, min=2, max=5)..."

# Supprimer l'ancien HPA
kubectl delete hpa backend-deployment

# Créer le fichier HPA basé sur la mémoire
cat > hpa-memory.yaml << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-deployment-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
EOF

# Appliquer le HPA basé sur la mémoire
kubectl apply -f hpa-memory.yaml

log_info "HPA RAM créé avec succès"

# Attendre un moment pour voir les métriques
log_info "Attente de la collecte des métriques mémoire..."
sleep 20

log_info "État du HPA basé sur RAM:"
kubectl describe hpa backend-deployment-hpa

# Étape 5: Vérifications finales
log_step "5. Vérifications finales..."

echo ""
echo "=== RÉSUMÉ DE LA CONFIGURATION ==="
echo ""

log_info "📊 État des déploiements:"
kubectl get deployments

echo ""
log_info "📈 État des HPA:"
kubectl get hpa

echo ""
log_info "🔍 Métriques actuelles:"
kubectl top pods -l app=backend 2>/dev/null || log_warning "Métriques pas encore disponibles"

echo ""
log_info "📋 Pods backend actuels:"
kubectl get pods -l app=backend

echo ""
echo "=== TESTS DE VALIDATION ==="

# Test 1: Vérifier que le HPA existe
if kubectl get hpa backend-deployment-hpa &>/dev/null; then
    log_info "✅ HPA 'backend-deployment-hpa' existe"
else
    log_error "❌ HPA 'backend-deployment-hpa' n'existe pas"
fi

# Test 2: Vérifier le nombre minimum de réplicas
CURRENT_REPLICAS=$(kubectl get deployment backend-deployment -o jsonpath='{.spec.replicas}')
if [ "$CURRENT_REPLICAS" -ge 2 ]; then
    log_info "✅ Nombre minimum de réplicas respecté ($CURRENT_REPLICAS >= 2)"
else
    log_warning "⚠️ Nombre de réplicas inférieur au minimum ($CURRENT_REPLICAS < 2)"
fi

echo ""
log_info "🎉 Configuration de la scalabilité horizontale terminée!"
echo ""
echo "Pour tester la scalabilité:"
echo "  # Générer de la charge:"
echo "  kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh"
echo "  # Dans le pod: while true; do wget -q -O- http://backend-service:4000; done"
echo ""
echo "  # Surveiller l'autoscaling:"
echo "  watch kubectl get hpa,pods"
echo ""
echo "Pour supprimer la configuration:"
echo "  kubectl delete hpa backend-deployment-hpa"
echo "  kubectl delete -f hpa-memory.yaml"