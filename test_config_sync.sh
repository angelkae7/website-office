#!/bin/bash
set -euo pipefail

# --- Paramètres (adapte si besoin) ---
CONTAINER="web"
PROJECT="/opt/drupal"
DRUSH="$PROJECT/vendor/bin/drush"

# --- Helpers ---
inc() { podman exec -it "$CONTAINER" bash -lc "cd $PROJECT && $*"; }

echo "==> Vérifications préalables…"
# Conteneur up ?
podman ps --format '{{.Names}}' | grep -q "^${CONTAINER}\$" || { echo "ERR: conteneur '${CONTAINER}' introuvable."; exit 1; }
# Drush présent ?
inc "[ -x $DRUSH ]" || { echo "ERR: Drush introuvable à $DRUSH"; exit 1; }
# Dossier sync
inc "test -d config/sync || mkdir -p config/sync"

# settings.php pointe bien vers ../config/sync ?
if ! inc "grep -q \"config_sync_directory\" web/sites/default/settings.php"; then
  echo "WARN: \$settings['config_sync_directory'] manquant dans settings.php (web/sites/default/settings.php)."
  echo "      Ajoute: \$settings['config_sync_directory'] = '../config/sync';"
fi

echo "==> Étape 1 : export (drush cex)…"
inc "$DRUSH cex -y"
inc "$DRUSH cr"

echo "==> Étape 2 : lecture du slogan attendu (depuis YAML)…"
EXPECTED_SLOGAN=$(inc "php -r '
\$y=file_get_contents(\"config/sync/system.site.yml\");
if(\$y===false){exit(0);}
if(preg_match(\"/^slogan:\\s*(.*)\$/m\", \$y, \$m)){
  \$v=trim(\$m[1]);
  // enlève éventuels guillemets YAML
  \$v=trim(\$v, \" \\\"'\''\");
  echo \$v;
}
'")

echo "     Slogan attendu (YAML): '${EXPECTED_SLOGAN}'"

TMP_SLOGAN="__TEST_CIM__$(date +%s)__"

echo "==> Étape 3 : créer un écart contrôlé en base (cset slogan='${TMP_SLOGAN}')…"
inc "$DRUSH cset system.site slogan '${TMP_SLOGAN}' -y"
inc "$DRUSH cr"

echo "==> Étape 4 : vérifier qu'il y a bien une différence (config:status)…"
if inc "$DRUSH config:status | grep -q '^\\s*Changed:\\s*system.site'"; then
  echo "     Différence détectée ✔"
else
  echo "WARN: aucune diff détectée, on continue quand même."
fi

echo "==> Étape 5 : import (drush cim)…"
inc "$DRUSH cim -y"
inc "$DRUSH cr"

echo "==> Étape 6 : contrôle final (le slogan en base doit correspondre au YAML)…"
CURRENT_SLOGAN=$(inc "$DRUSH php:eval 'echo \\Drupal::config(\"system.site\")->get(\"slogan\");'")
echo "     Slogan courant (DB) : '${CURRENT_SLOGAN}'"

if [ "${CURRENT_SLOGAN}" = "${EXPECTED_SLOGAN}" ]; then
  echo ""
  echo "✅ TEST OK : export/import de configuration fonctionnent (CEX/CIM)."
  exit 0
else
  echo ""
  echo "❌ TEST KO : le slogan DB ne matche pas le YAML."
  echo "   Attendu : '${EXPECTED_SLOGAN}'"
  echo "   Obtenu  : '${CURRENT_SLOGAN}'"
  exit 2
fi
