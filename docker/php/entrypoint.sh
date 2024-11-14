#!/bin/sh

# Assurez-vous que les permissions sont correctes pour les répertoires critiques

# Configuration des permissions pour les répertoires de cache et log
mkdir -p /var/www/var/cache /var/www/var/log
chown -R www-data:www-data /var/www/var
chmod -R 775 /var/www/var

# Vérification des permissions
if [ ! -w /var/www/var/cache ] || [ ! -w /var/www/var/log ]; then
    echo "Error: Permissions incorrectes sur /var/www/var/cache ou /var/www/var/log"
    exit 1
fi

# Lancer Apache en premier plan
exec apache2-foreground
