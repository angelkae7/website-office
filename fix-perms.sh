#!/bin/bash
# -------------------------------------------------------------------
# 🧩 Script pour corriger les permissions de Drupal sous Podman rootless
# -------------------------------------------------------------------

echo "🔧 Correction des permissions Drupal (sites/default/files)..."

# Aller dans le dossier cible
cd "$(dirname "$0")/web/sites/default" || exit

# Donner les droits à ton utilisateur local
sudo chown -R $USER:$USER files

# Donner les droits d'accès lecture/écriture/exécution (propriétaire et groupe)
sudo chmod -R 775 files

echo "✅ Permissions corrigées pour $(pwd)/files"
