#!/bin/bash

echo "🚀 Démarrage de Jenkins avec Docker..."

# Se déplacer dans le répertoire jenkins
cd "$(dirname "$0")"

# Build et démarrage du conteneur
docker-compose up -d --build

# Attendre que Jenkins démarre
echo "⏳ Attente du démarrage de Jenkins (30 secondes)..."
sleep 30

# Afficher le mot de passe initial
echo ""
echo "🔑 Mot de passe initial de Jenkins:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo ""
echo "✅ Jenkins est accessible sur: http://localhost:8080"
echo ""
echo "📝 Commandes utiles:"
echo "  - Arrêter Jenkins: docker-compose down"
echo "  - Voir les logs: docker-compose logs -f"
echo "  - Redémarrer: docker-compose restart"
