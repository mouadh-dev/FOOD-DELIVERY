#!/bin/bash

# Script pour accéder aux interfaces de gestion de l'application Food Delivery

echo "🗄️  Interfaces disponibles pour Food Delivery"
echo ""
echo "📊 APPLICATION:"
echo "  Frontend:     http://localhost:3000"
echo "  Admin Panel:  http://localhost:3001"
echo "  Backend API:  http://localhost:4000"
echo ""
echo "🗄️  BASE DE DONNÉES:"
echo "  MongoDB:      mongodb://localhost:27017"
echo "  Mongo Express: http://localhost:8081"
echo "    👤 Utilisateur: admin"
echo "    🔑 Mot de passe: password123"
echo ""
echo "💡 CONSEILS:"
echo "  • Mongo Express: Interface web pour MongoDB"
echo "  • MongoDB Compass: Application desktop (optionnel)"
echo "  • MongoDB Shell: Accès en ligne de commande"
echo ""

# Fonction pour ouvrir les URLs (optionnel)
read -p "Voulez-vous ouvrir Mongo Express dans le navigateur ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open >/dev/null 2>&1; then
        # macOS
        open http://localhost:8081
    elif command -v xdg-open >/dev/null 2>&1; then
        # Linux
        xdg-open http://localhost:8081
    else
        echo "Ouvrez manuellement: http://localhost:8081"
    fi
fi