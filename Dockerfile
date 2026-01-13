# Utiliser une version spécifique (pas latest) [cite: 270]
FROM nginx:1.25.3-alpine

# Métadonnées [cite: 271-274]
LABEL maintainer="TP DevOps"
LABEL description="Application DevOps sécurisée"

# Créer un utilisateur non-root [cite: 275-277]
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Installer les dépendances nécessaires et nettoyer le cache [cite: 279-281]
RUN apk add --no-cache ca-certificates && \
    rm -rf /var/cache/apk/*

# Copier les fichiers avec les bonnes permissions [cite: 283-285]
COPY --chown=appuser:appgroup nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=appuser:appgroup src/ /usr/share/nginx/html/

# Configurer les dossiers pour l'utilisateur non-root [cite: 290-292]
RUN touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/cache/nginx

# Passer à l'utilisateur non-root [cite: 293-294]
USER appuser

# Exposer le port 8080 (requis pour l'utilisateur non-root) [cite: 295-296]
EXPOSE 8080

# Health check [cite: 297-299]
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
