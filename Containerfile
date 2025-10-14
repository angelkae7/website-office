FROM docker.io/drupal:11-php8.3-apache

# libpq pour pgsql + libs pour GD
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libpq-dev libjpeg62-turbo-dev libpng-dev libfreetype6-dev git unzip \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) gd pdo_pgsql pgsql mbstring \
 && rm -rf /var/lib/apt/lists/*

# Définir un ServerName global pour supprimer le warning
RUN printf "ServerName localhost\n" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername


# (optionnel) plus de logs visibles en dev
ENV APACHE_LOG_DIR=/var/log/apache2
