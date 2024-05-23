# Dockerfile pour le back-end Symfony
FROM php:8.3.7-apache

# Installation des dépendances nécessaires
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxslt-dev

# Installation des extensions PHP nécessaires
RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    intl \
    opcache \
    mbstring \
    gd \
    xsl

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copie du code source Symfony dans le conteneur
COPY ./felix_junot_back /var/www/html

# Installation des dépendances du projet avec Composer
RUN composer install --no-scripts --no-autoloader --no-dev

# Génération de l'autoloader de Composer
RUN composer dump-autoload --optimize --classmap-authoritative