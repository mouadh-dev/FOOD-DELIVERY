# Utiliser l'image officielle Node.js version LTS
FROM node:18-alpine

# Installer les outils de build nécessaires pour bcrypt
RUN apk add --no-cache make gcc g++ python3

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers package.json et package-lock.json (si disponible)
COPY package*.json ./

# Installer les dépendances et recompiler bcrypt
RUN npm install && npm rebuild bcrypt --build-from-source

# Copier tout le code source
COPY . .

# Exposer le port sur lequel l'application va tourner
EXPOSE 4000

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs
RUN adduser -S backend -u 1001

# Changer le propriétaire des fichiers
RUN chown -R backend:nodejs /app
USER backend

# Commande pour démarrer l'application
CMD ["npm", "run", "server"]