#!/bin/bash

# Fonction pour vérifier si Apache est installé
function check_apache_installed {
    if ! command -v apache2ctl &> /dev/null; then
        echo "Apache n'est pas installé. Installation d'Apache..."
        sudo apt update
        sudo apt install apache2 -y
    fi
}

# Fonction pour vérifier si un module Apache est activé
function check_module {
    local module=$1
    if sudo apache2ctl -M 2>/dev/null | grep -q "$module"; then
        echo "Le module $module est activé."
    else
        echo "Le module $module n'est pas activé."
    fi
}

# Vérifier si Apache est installé
check_apache_installed

# Vérifier que les modules ssl et headers sont activés
echo "Vérification des modules Apache activés :"
check_module "ssl_module"
check_module "headers_module"

# Vérifier les options SSL dans le fichier de configuration
SSL_CONF="/etc/apache2/sites-available/moodle-ssl.conf"
if [ -f "$SSL_CONF" ]; then
    echo ""
    echo "Options SSL actives dans la configuration SSL :"
    grep -E "^(SSLEngine|SSLCertificateFile|SSLCertificateKeyFile|SSLProtocol|SSLCipherSuite|SSLHonorCipherOrder|SSLCompression|SSLSessionTickets|Header)" "$SSL_CONF"
else
    echo ""
    echo "Le fichier de configuration SSL $SSL_CONF n'existe pas."
fi
