FROM php:8.3.7-apache

# Configuration de base
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Mise à jour des paquets et installation des dépendances
RUN apt-get update \
    && apt-get install -qq -y --no-install-recommends \
    cron \
    vim \
    locales coreutils apt-utils git libicu-dev g++ libpng-dev libxml2-dev libzip-dev libonig-dev libxslt-dev unzip \
    && apt-get clean

# Configuration des locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Installer Composer
RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
    mv composer.phar /usr/local/bin/composer

# Installation des extensions PHP
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo pdo_mysql mysqli gd opcache intl zip calendar dom mbstring zip gd xsl bcmath && a2enmod rewrite
RUN pecl install apcu && docker-php-ext-enable apcu

# Installation des extensions supplémentaires
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions amqp

# Activer et configurer OpCache pour les performances
RUN echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Installer Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony \
    && ln -s /usr/local/bin/symfony /usr/bin/symfony

# Copier le projet dans le conteneur
WORKDIR /var/www
COPY felix_junot_back /var/www

# Copier les fichiers de configuration Apache
COPY docker/php/vhosts /etc/apache2/sites-enabled

# Ajouter le script d'entrée pour la configuration du fichier prod.log
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Utiliser www-data pour les permissions
RUN chown -R www-data:www-data /var/www

# Passer à l’utilisateur www-data pour exécuter le reste du fichier
USER www-data

# Exposer le port 80
EXPOSE 80

# Préparation pour le déploiement en production
# 1. Installer les dépendances avec Composer en mode production (sans dev)
RUN composer install --no-dev --optimize-autoloader

# 2. Générer le cache de production et faire le warmup
RUN php bin/console cache:clear --env=prod && \
    php bin/console cache:warmup --env=prod

# Utiliser le script d'entrée pour démarrer Apache
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
