#!/bin/bash

# Chemin vers votre projet
PROJECT_DIR="/root/var/www/felix_junot"

# Naviguer dans le dossier du projet
cd "$PROJECT_DIR" || exit

# Récupérer les dernières modifications depuis GitHub
echo ">>> Récupération des dernières modifications depuis GitHub..."
git pull origin main

# Mettre à jour les submodules
echo ">>> Mise à jour des submodules..."
git submodule update --init --recursive

# Construire et redémarrer les conteneurs Docker
echo ">>> Construction et redémarrage des conteneurs Docker..."
docker-compose down
docker-compose up -d --build

echo ">>> Les conteneurs Docker sont en cours d'exécution."

# Vérifier les logs pour détecter d'éventuelles erreurs
#echo ">>> Les conteneurs Docker sont en cours d'exécution. Vérification des logs..."
#docker-compose logs -f

# Ligne pour quitter la visualisation des logs après exécution
#echo ">>> Appuyez sur Ctrl+C pour quitter les logs à tout moment."
