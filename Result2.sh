#!/bin/bash

# Définir le chemin du fichier de configuration SSL
SSL_CONF="/etc/apache2/sites-available/moodle-ssl.conf"

# Fonction pour vérifier si un module Apache est activé
function check_module {
    local module=$1
    if apachectl -M 2>/dev/null | grep -q "$module"; then
        echo "Le module $module est activé."
    else
        echo "Le module $module n'est pas activé."
    fi
}

# Afficher tous les modules Apache activés
echo "Modules Apache activés:"
apachectl -M 2>/dev/null

# Vérifier que les modules ssl et headers sont activés
echo ""
echo "Vérification des modules requis:"
check_module "ssl_module"
check_module "headers_module"

# Vérifier que la configuration SSL est correcte
if [ -f "$SSL_CONF" ]; then
    echo ""
    echo "Le fichier de configuration SSL $SSL_CONF existe."
    echo "Options SSL actives dans la configuration SSL:"
    grep -E "^(SSLEngine|SSLCertificateFile|SSLCertificateKeyFile|SSLProtocol|SSLCipherSuite|SSLHonorCipherOrder|SSLCompression|SSLSessionTickets|Header)" "$SSL_CONF"
else
    echo ""
    echo "Le fichier de configuration SSL $SSL_CONF n'existe pas."
fi
