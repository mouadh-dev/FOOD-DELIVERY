#!/bin/bash

# Script de configuration initiale pour Food Delivery
# Usage: ./setup-env.sh

echo "🔧 Configuration initiale de Food Delivery"
echo ""

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

# Fonction pour générer une clé secrète
generate_secret() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32
    else
        # Fallback si openssl n'est pas disponible
        date +%s | sha256sum | base64 | head -c 32 ; echo
    fi
}

# Vérifier si les fichiers existent déjà
if [ -f ".env.docker" ]; then
    print_warning "Le fichier .env.docker existe déjà"
    read -p "Voulez-vous le remplacer ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Configuration annulée"
        exit 0
    fi
fi

# Copier les fichiers exemple
print_message "Copie des fichiers de configuration..."

if [ -f ".env.docker.example" ]; then
    cp .env.docker.example .env.docker
    print_success "Fichier .env.docker créé"
else
    print_error "Fichier .env.docker.example non trouvé"
    exit 1
fi

if [ -f "backend/.env.example" ]; then
    cp backend/.env.example backend/.env
    print_success "Fichier backend/.env créé"
else
    print_error "Fichier backend/.env.example non trouvé"
    exit 1
fi

# Générer des clés secrètes
print_message "Génération des clés secrètes..."
JWT_SECRET=$(generate_secret)
MONGO_PASSWORD=$(generate_secret | head -c 16)

# Remplacer les placeholders dans .env.docker
sed -i.bak "s/YOUR_JWT_SECRET_HERE/$JWT_SECRET/g" .env.docker
sed -i.bak "s/YOUR_PASSWORD_HERE/$MONGO_PASSWORD/g" .env.docker
rm .env.docker.bak 2>/dev/null || true

# Remplacer les placeholders dans backend/.env
sed -i.bak "s/YOUR_JWT_SECRET_HERE/$JWT_SECRET/g" backend/.env
rm backend/.env.bak 2>/dev/null || true

print_success "Clés secrètes générées automatiquement"

echo ""
print_warning "⚠️  IMPORTANT: Configuration manuelle requise"
echo ""
echo "1. 🔑 Stripe Secret Key:"
echo "   - Allez sur https://dashboard.stripe.com/apikeys"
echo "   - Copiez votre clé secrète (sk_test_...)"
echo "   - Remplacez 'YOUR_STRIPE_SECRET_KEY_HERE' dans:"
echo "     • .env.docker"
echo "     • backend/.env"
echo ""
echo "2. 🗄️  Configuration générée:"
echo "   • JWT Secret: $JWT_SECRET"
echo "   • Mongo Express Password: $MONGO_PASSWORD"
echo ""

print_message "Fichiers créés:"
echo "  ✅ .env.docker"
echo "  ✅ backend/.env"
echo ""

print_success "🎉 Configuration initiale terminée !"
echo ""
print_message "Prochaines étapes:"
echo "  1. Configurez votre clé Stripe"
echo "  2. Lancez l'application: ./docker-compose.sh up"
echo "  3. Accédez à: http://localhost:3000"