#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${GREEN}==============================="
    echo -e "$1"
    echo -e "===============================${NC}"
}

# Function to restart a service if not running
restart_service() {
    service_name=$1
    if systemctl is-active --quiet $service_name; then
        echo -e "${GREEN}[OK] $service_name is running${NC}"
    else
        echo -e "${RED}[INFO] $service_name is not running, restarting...${NC}"
        systemctl start $service_name
        if systemctl is-active --quiet $service_name; then
            echo -e "${GREEN}[OK] $service_name started successfully${NC}"
        else
            echo -e "${RED}[ERROR] Failed to start $service_name${NC}"
        fi
    fi
}

# Function to set file permissions
set_permissions() {
    file_path=$1
    permissions=$2
    echo "Setting permissions for $file_path to $permissions"
    chmod $permissions $file_path
}

# Function to set password expiration policy
set_password_policy() {
    policy_key=$1
    policy_value=$2
    echo "Setting $policy_key to $policy_value in /etc/login.defs"
    sed -i "s/^$policy_key.*/$policy_key $policy_value/" /etc/login.defs
}

# System Information
print_header "System Information"
echo "Remediation script started. Please review the changes made."

# User Authentication
print_header "User Authentication"
set_password_policy "PASS_MAX_DAYS" "90"
echo "Password expiration policy set to 90 days."

# Network Configuration
print_header "Network Configuration"

echo "Configuring firewall rules..."
ufw allow OpenSSH
ufw allow 'Apache Full'
ufw enable
echo "Firewall rules configured."

# File and Directory Permissions
print_header "File and Directory Permissions"
set_permissions "/var/www/html" "755"

# Apache2 Configuration
print_header "Apache2 Configuration"
restart_service "apache2"

# Moodle Configuration
print_header "Moodle Configuration"
set_permissions "/var/www/html/moodle/config.php" "640"
echo "Set permissions for /var/www/html/moodle/config.php to 640"

# Log File Analysis
print_header "Log File Analysis"
echo "No direct remediation for log analysis, please review logs manually."

# Package Updates
print_header "Package Updates"
echo "Updating package list and upgrading packages..."
apt update -qq && apt upgrade -y
echo "Packages updated."

# Summary
print_header "Remediation Summary"
echo -e "${GREEN}Remediation script completed.${NC}"

# Suggest further improvements
print_header "Suggestions for Further Improvement"
echo -e "${RED}[TODO] Regularly review and update security policies and configurations.${NC}"
echo -e "${RED}[TODO] Implement additional security measures as per ANSSI guidelines.${NC}"

# Save the output to a log file
exec &> remediation_log.txt

echo "Remediation log saved to remediation_log.txt"
