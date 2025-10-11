# 🐳 Scripts Docker pour Food Delivery

Cette application contient plusieurs scripts pour faciliter la gestion des conteneurs Docker.

## 📋 Scripts disponibles

| Script | Description | Usage |
|--------|-------------|-------|
| `start.sh` | Construit et lance toute l'application | `./start.sh` |
| `build.sh` | Construit toutes les images Docker | `./build.sh` |
| `run.sh` | Lance tous les conteneurs | `./run.sh` |
| `stop.sh` | Arrête tous les conteneurs | `./stop.sh` |
| `logs.sh` | Affiche les logs des conteneurs | `./logs.sh [service]` |
| `clean.sh` | Nettoie les ressources Docker | `./clean.sh` |

## 🚀 Démarrage rapide

### 1. Première utilisation
```bash
./start.sh
```
Ce script va :
- Construire toutes les images Docker
- Lancer tous les conteneurs
- Afficher les URLs d'accès

### 2. Utilisation normale
```bash
# Pour démarrer l'application
./run.sh

# Pour arrêter l'application
./stop.sh

# Pour voir les logs
./logs.sh

# Pour reconstruire les images
./build.sh
```

## 🌐 URLs de l'application

Une fois lancée, l'application sera accessible sur :

- **Frontend** : http://localhost:3000
- **Admin** : http://localhost:3001
- **Backend API** : http://localhost:4000

## 📝 Commandes utiles

### Voir les logs d'un service spécifique
```bash
./logs.sh backend    # Logs du backend
./logs.sh frontend   # Logs du frontend
./logs.sh admin      # Logs de l'admin
./logs.sh           # Tous les logs
```

### Suivre les logs en temps réel
```bash
docker logs -f food-delivery-backend-container
docker logs -f food-delivery-frontend-container
docker logs -f food-delivery-admin-container
```

### Vérifier l'état des conteneurs
```bash
docker ps                    # Conteneurs en cours
docker ps -a                # Tous les conteneurs
docker images | grep food   # Images Food Delivery
```

## 🔧 Dépannage

### Problème de port déjà utilisé
```bash
# Voir ce qui utilise le port
lsof -i :3000
lsof -i :3001
lsof -i :4000

# Arrêter les conteneurs existants
./stop.sh
```

### Problème de build
```bash
# Nettoyer et reconstruire
./clean.sh
./build.sh
```

### Réinitialisation complète
```bash
./clean.sh
./start.sh
```

## 📁 Structure des services

```
Food-Delivery/
├── backend/           # API Node.js/Express (Port 4000)
├── frontend/          # Application React client (Port 3000)
├── admin/            # Panel d'administration React (Port 3001)
├── build.sh          # Script de construction
├── run.sh            # Script de lancement
├── stop.sh           # Script d'arrêt
├── logs.sh           # Script de logs
├── clean.sh          # Script de nettoyage
└── start.sh          # Script tout-en-un
```

## ⚠️ Prérequis

- Docker installé et en cours d'exécution
- Ports 3000, 3001, et 4000 disponibles
- Au moins 2GB d'espace disque libre