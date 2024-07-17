#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Initialize progress variables
total_checks=11
completed_checks=0

# Function to print section headers
print_header() {
    echo -e "\n${GREEN}==============================="
    echo -e "$1"
    echo -e "===============================${NC}"
}

# Function to check if a service is running
check_service() {
    service_name=$1
    if systemctl is-active --quiet $service_name; then
        echo -e "${GREEN}[OK] $service_name is running${NC}"
    else
        echo -e "${RED}[ERROR] $service_name is not running${NC}"
    fi
    ((completed_checks++))
    show_progress
}

# Function to show progress
show_progress() {
    percentage=$(( (completed_checks * 100) / total_checks ))
    echo -e "${GREEN}Progress: $percentage% completed${NC}"
}

# System Information
print_header "System Information"
echo "Hostname: $(hostname)"
echo "Operating System: $(lsb_release -d | cut -f2)"
echo "Kernel Version: $(uname -r)"
((completed_checks++))
show_progress

# User Authentication
print_header "User Authentication"
echo "Checking for password expiration policy:"
grep PASS_MAX_DAYS /etc/login.defs
((completed_checks++))
show_progress

echo "Checking for locked users:"
passwd -S | grep "L"
((completed_checks++))
show_progress

# Network Configuration
print_header "Network Configuration"
echo "Active Network Interfaces:"
ip -br address show
((completed_checks++))
show_progress

echo "Checking for open ports:"
ss -tuln
((completed_checks++))
show_progress

echo "Checking firewall status:"
ufw status
((completed_checks++))
show_progress

# File and Directory Permissions
print_header "File and Directory Permissions"
echo "Checking permissions for /var/www/html:"
ls -ld /var/www/html
((completed_checks++))
show_progress

# Apache2 Configuration
print_header "Apache2 Configuration"
check_service apache2

echo "Checking Apache2 configuration syntax:"
apachectl configtest
((completed_checks++))
show_progress

echo "Checking for loaded Apache2 modules:"
apachectl -M
((completed_checks++))
show_progress

# Moodle Configuration
print_header "Moodle Configuration"
echo "Checking Moodle config file permissions:"
ls -l /var/www/html/moodle/config.php
((completed_checks++))
show_progress

echo "Checking if config.php is readable by others:"
if [ $(stat -c "%a" /var/www/html/moodle/config.php) -eq 640 ]; then
    echo -e "${GREEN}[OK] config.php has appropriate permissions${NC}"
else
    echo -e "${RED}[ERROR] config.php permissions are not set correctly${NC}"
fi
((completed_checks++))
show_progress

# Log File Analysis
print_header "Log File Analysis"
echo "Checking for recent logins:"
last
((completed_checks++))
show_progress

echo "Checking for failed login attempts:"
grep "authentication failure" /var/log/auth.log
((completed_checks++))
show_progress

# Package Updates
print_header "Package Updates"
echo "Checking for available updates:"
apt update -qq
apt list --upgradable
((completed_checks++))
show_progress

# Summary
print_header "Audit Summary"
echo -e "${GREEN}System audit completed.${NC}"

# Suggest improvements
print_header "Suggestions for Improvement"
echo -e "${RED}[TODO] Implement additional checks as required by ANSSI guidelines.${NC}"

# Save the output to a log file
exec &> audit_log.txt

echo "Audit log saved to audit_log.txt"
