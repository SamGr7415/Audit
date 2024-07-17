#!/bin/bash

# Variables
DOMAIN="academicefrei.site"
ADMIN_EMAIL="your-email@academicefrei.site"
SSL_CONF="/etc/apache2/sites-available/moodle-ssl.conf"
PASSWORD_FILE="/root/mariadb_passwords.txt"

# Mettre à jour la liste des paquets et mettre à niveau les paquets
apt update
apt upgrade -y

# Installer les paquets nécessaires pour PHP et Git
apt install -y php-fpm php-mysql php-xml php-curl php-zip php-gd php-intl php-mbstring git

# Vérifier si les commandes a2ensite et a2enmod sont disponibles
if ! command -v a2ensite &> /dev/null || ! command -v a2enmod &> /dev/null; then
    echo "Les commandes a2ensite et a2enmod ne sont pas disponibles. Installation du package apache2."
    apt install -y apache2
fi

# Sauvegarder le fichier de configuration SSL existant s'il existe
if [ -f $SSL_CONF ]; then
    cp $SSL_CONF ${SSL_CONF}.bak
fi

# Mettre à jour la configuration SSL
cat <<EOF > $SSL_CONF
<VirtualHost *:443>
    ServerAdmin $ADMIN_EMAIL
    ServerName $DOMAIN
    DocumentRoot /var/www/html/moodle

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN/privkey.pem

    <Directory /var/www/html/moodle>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Configuration du protocole SSL et de la suite de chiffrement
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite HIGH:!aNULL:!MD5:!3DES
    SSLHonorCipherOrder on
    SSLCompression off
    SSLSessionTickets off

    # En-têtes pour la sécurité
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
    Header always set Content-Security-Policy "default-src 'self'"

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Activer la configuration du site SSL et les modules nécessaires
/usr/sbin/a2ensite moodle-ssl.conf
/usr/sbin/a2enmod ssl
/usr/sbin/a2enmod headers

# Redémarrer Apache pour appliquer les modifications
systemctl restart apache2

echo "Configuration SSL/TLS durcie pour Apache2 est appliquée."

# Afficher les mots de passe générés s'ils ont été précédemment enregistrés
if [ -f $PASSWORD_FILE ]; then
    echo "Les mots de passe ont été enregistrés dans ${PASSWORD_FILE}."
    cat $PASSWORD_FILE
fi
