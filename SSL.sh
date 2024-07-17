#!/bin/bash

# Variables
DOMAIN="academicefrei.site"
ADMIN_EMAIL="your-email@academicefrei.site"
SSL_CONF="/etc/apache2/sites-available/moodle-ssl.conf"
PASSWORD_FILE="/root/mariadb_passwords.txt"

# Sauvegarder la configuration SSL
cp $SSL_CONF ${SSL_CONF}.bak

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

    # Configuration des protocoles SSL
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite HIGH:!aNULL:!MD5:!3DES
    SSLHonorCipherOrder on
    SSLCompression off
    SSLSessionTickets off

    # Ajouts des Headers pour de la Sécurité
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
    Header always set Content-Security-Policy "default-src 'self'"

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Activation du SSL et des Headers
a2ensite moodle-ssl.conf
a2enmod ssl
a2enmod headers

# Redémarrage de Apache
systemctl restart apache2

echo "Configuration SSL/TLS durcie pour Apache2 est appliquée."

# Affichage du MDP pour sauvegarde
if [ -f $PASSWORD_FILE ]; then
    echo "Passwords have been saved to ${PASSWORD_FILE}."
    cat $PASSWORD_FILE
fi
