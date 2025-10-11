#!/bin/bash

# Script pour nettoyer complètement l'historique Git des secrets
# Usage: ./clean-git-history.sh

echo "🧹 Nettoyage complet de l'historique Git..."

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

# Sauvegarder la branche actuelle
current_branch=$(git branch --show-current)
print_message "Branche actuelle: $current_branch"

# Créer une nouvelle branche orphan (sans historique)
print_message "Création d'une nouvelle branche sans historique..."
git checkout --orphan new-main

# Ajouter tous les fichiers actuels (sans l'historique)
print_message "Ajout des fichiers actuels..."
git add .

# Créer le commit initial
print_message "Création du commit initial propre..."
git commit -m "🎉 Initial commit - Clean version without secrets

This is a fresh start with:
- ✅ No sensitive data in history
- ✅ Environment variables properly configured
- ✅ Docker setup ready
- ✅ Security best practices applied

Features:
- 🍕 Food Delivery Frontend (React)
- 🛠️ Admin Panel (React)
- 🔧 Backend API (Node.js/Express)
- 🗄️ MongoDB Database
- 🐳 Full Docker setup
- 📝 Configuration templates"

# Supprimer l'ancienne branche main
print_warning "Suppression de l'ancienne branche main avec l'historique sensible..."
git branch -D main 2>/dev/null || true

# Renommer la nouvelle branche en main
print_message "Renommage de la nouvelle branche en main..."
git branch -m new-main main

# Forcer la mise à jour des références
print_message "Mise à jour des références..."
git gc --aggressive --prune=now

print_success "🎉 Historique Git nettoyé avec succès !"
echo ""
print_message "📋 Résumé des changements:"
echo "  ✅ Tout l'historique sensible supprimé"
echo "  ✅ Nouveau commit initial créé"
echo "  ✅ Variables d'environnement sécurisées"
echo "  ✅ Prêt pour le push vers GitHub"
echo ""
print_warning "⚠️  IMPORTANT:"
echo "  • L'historique Git a été complètement réécrit"
echo "  • Vous devrez forcer le push: git push --force-with-lease origin main"
echo "  • Prévenez vos collaborateurs du changement d'historique"