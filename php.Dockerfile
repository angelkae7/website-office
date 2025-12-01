FROM php:8.3-fpm

# Extensions nécessaires pour PostgreSQL + GD pour Drupal
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       libpq-dev \
       libjpeg-dev \
       libpng-dev \
       libfreetype6-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install pdo_pgsql gd \
  && rm -rf /var/lib/apt/lists/*
