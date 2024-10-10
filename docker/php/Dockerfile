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

# Ajouter un utilisateur non-root et configurer les permissions
RUN useradd -ms /bin/bash symfony_user

# Copier le projet dans le conteneur
WORKDIR /var/www
COPY felix_junot_back /var/www

# Fixer les permissions pour les fichiers montés
RUN chown -R symfony_user:www-data /var/www

# Créer le répertoire var/log et les fichiers de log avec les bonnes permissions
RUN mkdir -p /var/www/var/log \
	&& touch /var/www/var/log/dev.log /var/www/var/log/test.log \
	&& chown symfony_user:www-data /var/www/var/log/dev.log /var/www/var/log/test.log \
	&& chmod 664 /var/www/var/log/dev.log /var/www/var/log/test.log

# Définir les permissions pour le répertoire var/log
RUN chown -R symfony_user:www-data /var/www/var/log \
	&& chmod -R 755 /var/www/var/log

# Copier les fichiers de configuration Apache
COPY docker/php/vhosts /etc/apache2/sites-enabled

# Passer à l'utilisateur non-root
USER symfony_user

# Exposer le port 80
EXPOSE 80

# Démarrer Apache et nettoyer le cache Symfony avant
CMD ["sh", "-c", "php bin/console cache:clear --env=prod && apache2-foreground"]
