# ------------------------------
# Makefile - Environnement Drupal OPT-NC
# ------------------------------

PROJECT_NAME=opt-site

# Démarrer la stack
start:
	podman-compose up -d
	@echo "🔵 Stack démarrée : http://localhost:8080"

# Arrêter la stack
stop:
	podman-compose down
	@echo "🟠 Stack arrêtée."

# Rebuild complet + démarrage
rebuild:
	podman-compose down
	podman-compose build
	podman-compose up -d
	@echo "🔧 Stack reconstruite et démarrée."

# Entrer dans PHP
php:
	podman exec -it $(PROJECT_NAME)_php bash

# Entrer dans PostgreSQL
db:
	podman exec -it $(PROJECT_NAME)_db bash

# Logs Nginx
logs-web:
	podman logs $(PROJECT_NAME)_web --tail=50

# Logs PHP
logs-php:
	podman logs $(PROJECT_NAME)_php --tail=50

# Logs DB
logs-db:
	podman logs $(PROJECT_NAME)_db --tail=50

# Clear Drupal cache
cr:
	podman exec -it $(PROJECT_NAME)_php bash -c "cd /var/www/web && ../vendor/bin/drush cr"
	@echo "🧹 Cache Drupal vidé."

# Ouvrir le site dans le navigateur
open:
	xdg-open "http://localhost:8080" >/dev/null 2>&1 || open "http://localhost:8080"
	@echo "🌐 Site ouvert."

# Vérifier les conteneurs actifs
status:
	podman ps
