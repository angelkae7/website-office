
# 🌐 OPT-NC — Environnement Drupal local  
**Stack : Podman • Nginx • PHP-FPM • PostgreSQL**

Ce dépôt contient l’environnement de développement du site Drupal OPT-NC, entièrement conteneurisé avec **Podman** et configuré pour être reproductible, stable et facile à maintenir.

---

## 🚀 Fonctionnalités principales

- Environnement **100% isolé** (Nginx + PHP-FPM + PostgreSQL)
- Compatible Drupal 10/11
- Image PHP personnalisée incluant :
  - `pdo_pgsql`
  - `gd`
  - `opcache`
  - `pdo_sqlite`
- Configuration Nginx optimisée pour Drupal
- Volume persistant pour la base de données
- Makefile pour automatiser toutes les commandes

---

# 📁 Structure du projet

```
opt-site/
│
├── web/                     # Racine Drupal (core/, modules/, themes/)
├── vendor/                  # Dépendances Composer
│
├── docker-compose.yml       # Stack Podman
├── nginx.conf               # Configuration Nginx
├── php.Dockerfile           # Build PHP-FPM
│
├── Makefile                 # Commandes automatiques
└── README.md
```

---

# ▶️ Démarrer l’environnement

### **1. Lancer la stack**

```bash
make start
```

Le site devient accessible ici :

👉 http://localhost:8080

---

# 🛑 Arrêter l’environnement

```bash
make stop
```

Les conteneurs sont supprimés, mais **la base est conservée**.

---

# 🔄 Rebuild complet (en cas de modification PHP)

```bash
make rebuild
```

---

# 🐘 Base de données

Accéder à PostgreSQL :

```bash
make db
```

---

# 🧼 Drupal cache

```bash
make cr
```

---

# 📦 Installer les dépendances PHP

En local :

```bash
composer install
```

Si votre version de PHP est plus ancienne que Drupal :

```bash
COMPOSER_IGNORE_PLATFORM_REQS=1 composer install
```

---

# 📜 Logs

Nginx :

```bash
make logs-web
```

PHP :

```bash
make logs-php
```

DB :

```bash
make logs-db
```

---

# 📝 Notes importantes

- Le projet utilise **Nginx**, pas Apache.
- La base PostgreSQL est stockée dans un volume persistant.
- L’environnement est entièrement reproductible via `podman-compose`.

---

# 📣 Auteure

Projet développé et maintenu par **Angèle Kaloï — OPT-NC**.  
Environnement technique supervisé et documenté avec ChatGPT.

---
