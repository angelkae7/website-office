FROM docker.io/drupal:11-php8.3-apache

# libs: Postgres, GD (jpeg+freetype), mbstring (libonig), utilitaires
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libpq-dev libjpeg62-turbo-dev libpng-dev libfreetype6-dev libonig-dev \
      git unzip \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) gd pdo_pgsql pgsql mbstring \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Définir un ServerName global (supprime le warning Apache)
RUN printf "ServerName localhost\n" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername

ENV APACHE_LOG_DIR=/var/log/apache2
