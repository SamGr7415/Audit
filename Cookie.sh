#!/bin/bash

# Fonction pour générer un nouveau token aléatoire
generate_token() {
    openssl rand -hex 16  # Génère un token de 32 caractères hexadécimaux
}

# Générer un nouveau token
new_token=$(generate_token)

# Définir le chemin du fichier de configuration SSL de Moodle
SSL_CONF="/etc/apache2/sites-available/moodle-ssl.conf"

# Vérifier si le fichier de configuration existe
if [ -f "$SSL_CONF" ]; then
    # Mettre à jour le fichier de configuration Apache avec le nouveau token
    sudo sed -i "s/\(^Header always set Set-Cookie \"mycookie=\).*\(\"; HttpOnly; Secure; SameSite=Strict\"\)/\1${new_token}\2/" "$SSL_CONF"

    # Redémarrer Apache pour appliquer les modifications
    sudo systemctl restart apache2

    echo "Cookie avec token aléatoire mis à jour avec succès."
else
    echo "Le fichier de configuration SSL $SSL_CONF n'existe pas."
    exit 1
fi
