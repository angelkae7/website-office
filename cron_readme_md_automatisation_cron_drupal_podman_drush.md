# Automatisation du cron Drupal (Podman + Drush)

Ce document décrit la mise en place, la supervision et la passation DSI d’un cron Drupal exécuté via Podman et Drush. Il couvre :
- Le script Bash de lancement
- La planification via crontab
- Les logs et leur rotation simple
- Les commandes de diagnostic et de dépannage
- Les variantes Docker et l’intégration DSI

---

## 1) Prérequis
- Environnement conteneurisé avec un conteneur applicatif nommé `web` (adapter si différent)
- Projet Drupal monté dans le conteneur sous `/opt/drupal` (adapter si différent)
- Drush disponible dans le projet (`/opt/drupal/vendor/bin/drush`)
- Podman installé sur l’hôte et accessible dans le PATH

> Vérifications rapides :
```bash
podman ps                   # le conteneur "web" doit être up
podman exec -it web php -v  # PHP 8.3+ recommandé pour Drupal 11
podman exec -it web bash -lc 'cd /opt/drupal && ./vendor/bin/drush --version'
```

---

## 2) Script de cron
Créer le fichier `~/dev/opt-site/run_drupal_cron.sh` avec le contenu ci‑dessous, puis le rendre exécutable.

```bash
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
```

Rendre exécutable :
```bash
chmod +x /home/angelkael/dev/opt-site/run_drupal_cron.sh
```

> Adaptations possibles :
> - Changer `web` si le conteneur a un autre nom
> - Changer `/opt/drupal` si le docroot projet est ailleurs
> - Changer l’horaire d’indexation (02h) ou commenter le bloc si non souhaité

---

## 3) Planification avec `crontab`
Planifier l’exécution **toutes les heures**.

### Méthode simple (sans éditeur)
```bash
( crontab -l 2>/dev/null; echo '0 * * * * /home/angelkael/dev/opt-site/run_drupal_cron.sh' ) | crontab -
```

### Méthode classique (nano)
```bash
crontab -e
# Ajouter la ligne suivante :
0 * * * * /home/angelkael/dev/opt-site/run_drupal_cron.sh
```

### Démarrage du service cron (si nécessaire)
```bash
sudo service cron status
sudo service cron start
```

> Test minute par minute (temporaire) :
> ```bash
> crontab -e
> * * * * * /home/angelkael/dev/opt-site/run_drupal_cron.sh
> ```
> Revenir ensuite à l’horaire horaire : `0 * * * * ...`

---

## 4) Logs et consultation
Les journaux sont écrits dans `~/dev/opt-site/logs/` avec un fichier par jour : `cron_YYYY-MM-DD.log`.

Commandes utiles :
```bash
# Lancer une première fois et générer le log du jour
/home/angelkael/dev/opt-site/run_drupal_cron.sh

# Lister les logs\pls -lh /home/angelkael/dev/opt-site/logs/

# Voir la fin du log du jour
tail -n 50 /home/angelkael/dev/opt-site/logs/cron_$(date +%Y-%m-%d).log

# Suivre en temps réel
tail -f /home/angelkael/dev/opt-site/logs/cron_$(date +%Y-%m-%d).log

# Rechercher des erreurs
grep -iE 'error|warning|failed' /home/angelkael/dev/opt-site/logs/cron_$(date +%Y-%m-%d).log || true
```

---

## 5) Vérifications Drupal
```bash
# Rapport d’exigences Drupal (rq = core:requirements)
podman exec -it web bash -lc 'cd /opt/drupal && ./vendor/bin/drush rq'

# Statut (versions, DB, PHP, etc.)
podman exec -it web bash -lc 'cd /opt/drupal && ./vendor/bin/drush status'
```

Indicateurs attendus :
- "Tâches planifiées (cron)… Dernière exécution : il y a X s/min"
- Avertissements résiduels tolérables (ex. GD bundled)

---

## 6) Dépannage
- **Pas de log généré** :
  - Vérifier droits et exécution :
    ```bash
    ls -l /home/angelkael/dev/opt-site/run_drupal_cron.sh
    chmod +x /home/angelkael/dev/opt-site/run_drupal_cron.sh
    ```
  - Vérifier service cron :
    ```bash
    sudo service cron status
    ```
  - Vérifier chemin script dans la crontab : `crontab -l`
- **Erreur conteneur** : `podman exec: container not found`
  - Vérifier `podman ps` et adapter le nom `web` dans le script
- **Drush introuvable** : `./vendor/bin/drush: not found`
  - Vérifier le chemin projet (`/opt/drupal`) et l’installation Drush
- **Permissions fichiers** :
  - S’assurer que l’utilisateur cron peut écrire dans `~/dev/opt-site/logs/`

---

## 7) Variantes et intégration DSI
- **Docker au lieu de Podman** : remplacer `podman exec` par `docker exec`.
- **Cron côté conteneur** :
  - Déployer le script dans l’image ou un volume et créer une crontab dans le conteneur
  - Avantage : isolation, inconvénient : gestion de la persistance/lifecycle du conteneur
- **Ansible / Jenkins** :
  - Exposer ce script comme tâche Ansible (copy + cron module)
  - Journaliser dans `/var/log/drupal/cron_YYYY-MM-DD.log` en prod

### Variables à documenter pour la DSI
- Nom du conteneur applicatif (`web`)
- Chemin du projet dans le conteneur (`/opt/drupal`)
- Fréquence cron (horaire par défaut)
- Emplacement des logs sur l’hôte (`~/dev/opt-site/logs/`) ou en prod (`/var/log/drupal/`)

---

## 8) Exemples d’horaires utiles
```cron
# Toutes les heures à HH:00
0 * * * * /home/angelkael/dev/opt-site/run_drupal_cron.sh

# Toutes les 30 minutes
*/30 * * * * /home/angelkael/dev/opt-site/run_drupal_cron.sh

# Tous les jours à 02:15
15 2 * * * /home/angelkael/dev/opt-site/run_drupal_cron.sh
```

---

## 9) Annexe – Commandes utiles
```bash
# Forcer une exécution immédiate (hors cron)
/home/angelkael/dev/opt-site/run_drupal_cron.sh

# Mettre à jour les traductions
podman exec -it web bash -lc 'cd /opt/drupal && ./vendor/bin/drush locale:check && ./vendor/bin/drush locale:update'

# Lancer le cron et l’indexation manuellement
podman exec -it web bash -lc 'cd /opt/drupal && ./vendor/bin/drush core:cron'
podman exec -it web bash -lc 'cd /opt/drupal && ./vendor/bin/drush search:index'
```

---

## 10) Passation DSI (copier-coller)
- Script : `/home/angelkael/dev/opt-site/run_drupal_cron.sh` (ou `/var/www/opt-drupal/cron/run_drupal_cron.sh` en prod)
- Planification : crontab système (`crontab -e`) ou rôle Ansible
- Logs : `~/dev/opt-site/logs/` en dev, `/var/log/drupal/` en prod
- Variantes : `podman exec` ↔ `docker exec`, cron hôte ↔ cron conteneur

Ce document peut être intégré tel quel au dépôt du projet pour exploitation et reprise par la DSI.

