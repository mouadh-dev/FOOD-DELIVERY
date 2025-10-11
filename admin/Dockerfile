# Image multi-stage pour optimiser la taille finale

# Stage 1: Build de l'application
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Build argument pour l'URL du backend
ARG VITE_BACKEND_URL=http://localhost:4000
ENV VITE_BACKEND_URL=${VITE_BACKEND_URL}

RUN npm run build

# Stage 2: Servir l'application avec nginx
FROM nginx:alpine

# Copier les fichiers build depuis le stage précédent
COPY --from=builder /app/dist /usr/share/nginx/html

# Copier la configuration nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80
EXPOSE 80

# Nginx se lance automatiquement
CMD ["nginx", "-g", "daemon off;"]