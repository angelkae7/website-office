#!/bin/bash
# --------------------------------------------------------------------
# Script d’exécution du cron Drupal (compatible Podman)
# --------------------------------------------------------------------

# Emplacement du projet (côté hôte)
PROJECT_PATH="/home/angelkael/dev/opt-site"
LOG_DIR="$PROJECT_PATH/logs"
LOG_FILE="$LOG_DIR/cron_$(date +%Y-%m-%d).log"

# Crée le dossier de logs si inexistant
mkdir -p "$LOG_DIR"

# Timestamp début
echo "----------------------------------------" >> "$LOG_FILE"
echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] Début du cron Drupal" >> "$LOG_FILE"

# Lancer le cron Drupal dans le conteneur
podman exec -it web bash -lc "cd /opt/drupal && ./vendor/bin/drush core:cron" >> "$LOG_FILE" 2>&1

# (Optionnel) Indexation 1x/jour à 02h
if [ "$(date +%H)" = "02" ]; then
  echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] Lancement de l’indexation" >> "$LOG_FILE"
  podman exec -it web bash -lc "cd /opt/drupal && ./vendor/bin/drush search:index" >> "$LOG_FILE" 2>&1
fi

# Timestamp fin
echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] Fin du cron Drupal" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
