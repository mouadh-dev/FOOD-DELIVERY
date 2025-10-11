# 🔐 Configuration des Variables d'Environnement

## ⚠️ Important
Les fichiers de configuration contenant des clés secrètes ne sont pas inclus dans ce repository pour des raisons de sécurité.

## 🛠️ Configuration requise

### 1. Backend
```bash
# Copiez le fichier exemple
cp backend/.env.example backend/.env

# Éditez et ajoutez vos vraies valeurs
nano backend/.env
```

### 2. Docker Compose
```bash
# Copiez le fichier exemple
cp .env.docker.example .env.docker

# Éditez et ajoutez vos vraies valeurs
nano .env.docker
```

## 🔑 Variables à configurer

### JWT_SECRET
Générez une clé secrète forte :
```bash
openssl rand -base64 32
```

### STRIPE_SECRET_KEY
Obtenez votre clé depuis [Stripe Dashboard](https://dashboard.stripe.com/apikeys)

### MONGO_EXPRESS_PASSWORD
Choisissez un mot de passe fort pour l'interface MongoDB

## 📁 Structure après configuration
```
├── .env.docker          # Configuration Docker (non versionné)
├── .env.docker.example  # Modèle de configuration
├── backend/
│   ├── .env            # Variables backend (non versionné)
│   ├── .env.example    # Modèle backend
│   └── uploads/        # Dossier uploads (non versionné)
```

## 🚀 Démarrage après configuration
```bash
# Démarrer l'application
./docker-compose.sh up
# ou
docker-compose up -d
```