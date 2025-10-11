# 🐳 Guide Docker Compose - Food Delivery

## 📋 Qu'est-ce que Docker Compose ?

Docker Compose est un outil qui permet de définir et gérer des applications multi-conteneurs. Au lieu de lancer chaque conteneur individuellement, on peut tout orchestrer avec un seul fichier.

## 🗂️ Fichiers Docker Compose

| Fichier | Description | Usage |
|---------|-------------|-------|
| `docker-compose.yaml` | Configuration de production | Applications complètes |
| `docker-compose.dev.yaml` | Configuration de développement | Avec hot reload |
| `.env.docker` | Variables d'environnement | Configuration centralisée |
| `docker-compose.sh` | Script d'aide | Commandes simplifiées |

## 🚀 Utilisation rapide

### Option 1: Avec le script (Recommandé pour débutants)
```bash
# Démarrer l'application
./docker-compose.sh up

# Voir les logs
./docker-compose.sh logs

# Arrêter l'application
./docker-compose.sh down

# Aide
./docker-compose.sh help
```

### Option 2: Commandes Docker Compose directes
```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Voir les logs
docker-compose logs -f

# Voir l'état des services
docker-compose ps
```

## 🏗️ Architecture des services

```
┌─────────────────────────────────────────────────┐
│                Food Delivery App                │
├─────────────────────────────────────────────────┤
│  Frontend (React)     │  Admin (React)          │
│  Port: 3000           │  Port: 3001             │
│  http://localhost:3000│  http://localhost:3001  │
├─────────────────────────────────────────────────┤
│             Backend (Node.js/Express)            │
│             Port: 4000                           │
│             http://localhost:4000                │
├─────────────────────────────────────────────────┤
│             MongoDB Database                     │
│             Port: 27017                          │
│             mongodb://localhost:27017            │
└─────────────────────────────────────────────────┘
```

## 📊 Services inclus

### 🗄️ MongoDB
- **Image**: `mongo:7.0`
- **Port**: `27017`
- **Volume**: Données persistantes
- **Réseau**: `food-delivery-network`

### 🔧 Backend API
- **Build**: `./backend/Dockerfile`
- **Port**: `4000`
- **Variables**: JWT, MongoDB, Stripe
- **Volumes**: Dossier uploads

### 📱 Frontend
- **Build**: `./frontend/Dockerfile`
- **Port**: `3000` (Nginx sur port 80 interne)
- **Dépendance**: Backend

### 🛠️ Admin Panel
- **Build**: `./admin/Dockerfile`
- **Port**: `3001` (Nginx sur port 80 interne)
- **Dépendance**: Backend

## 🌐 URLs après démarrage

Une fois l'application lancée :

- **Application client** : http://localhost:3000
- **Panel admin** : http://localhost:3001
- **API Backend** : http://localhost:4000
- **Base de données** : mongodb://localhost:27017

## 🔧 Commandes utiles

### Gestion des services
```bash
# Démarrer un service spécifique
docker-compose up -d backend

# Reconstruire un service
docker-compose build frontend

# Redémarrer un service
docker-compose restart backend

# Voir les logs d'un service
docker-compose logs -f backend
```

### Développement
```bash
# Mode développement avec hot reload
docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml up -d

# Accéder au shell d'un conteneur
docker-compose exec backend sh
docker-compose exec mongodb mongosh
```

### Maintenance
```bash
# Mettre à jour les images
docker-compose pull

# Supprimer les volumes (⚠️ Efface les données)
docker-compose down -v

# Reconstruire sans cache
docker-compose build --no-cache
```

## 🐛 Dépannage

### Problème de port occupé
```bash
# Vérifier les ports utilisés
netstat -tulpn | grep :3000
lsof -i :3000

# Arrêter tous les services
docker-compose down
```

### Problème de base de données
```bash
# Voir les logs MongoDB
docker-compose logs mongodb

# Accéder à MongoDB
docker-compose exec mongodb mongosh

# Réinitialiser la base de données
docker-compose down -v
docker-compose up -d
```

### Problème de build
```bash
# Nettoyer et reconstruire
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 📁 Structure du réseau

Tous les services communiquent via le réseau `food-delivery-network` :

- **Frontend** → **Backend** : Via `http://backend:4000`
- **Backend** → **MongoDB** : Via `mongodb://mongodb:27017`
- **Admin** → **Backend** : Via `http://backend:4000`

## 💾 Persistance des données

- **Volume MongoDB** : `food-delivery-mongodb-data`
- **Uploads Backend** : `./backend/uploads`

Les données MongoDB sont sauvegardées même après `docker-compose down`.

## ⚠️ Notes importantes

1. **Première utilisation** : Les images seront construites automatiquement
2. **Ports requis** : 3000, 3001, 4000, 27017 doivent être libres
3. **Variables d'environnement** : Modifiez `.env.docker` si nécessaire
4. **Développement** : Utilisez `docker-compose.dev.yaml` pour le hot reload