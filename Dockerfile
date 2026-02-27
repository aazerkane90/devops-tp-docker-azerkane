# Utilisation d'une version stable et légère
FROM nginx:1.29-alpine

LABEL maintainer="TP DevOps"
LABEL description="Application DevOps sécurisée sur port 8081"

# Création d'un utilisateur non-privilégié
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Mise a jour des paquets systeme pour corriger les CVE critiques
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates

# Copie des fichiers avec les bonnes permissions
COPY --chown=appuser:appgroup nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=appuser:appgroup src/ /usr/share/nginx/html/

# Préparation des dossiers pour l'utilisateur non-root
RUN touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/cache/nginx

USER appuser

# Exposition du port 8081
EXPOSE 8081

# Healthcheck configuré sur le port 8081
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8081/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
