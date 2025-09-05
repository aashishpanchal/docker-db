#!/bin/bash

# Security Check Script
# Usage: ./bin/security-check.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Docker Database Stack Security Check${NC}"
echo "========================================"

# Check if .env file exists and has proper permissions
echo -e "\n${YELLOW}📋 Environment Security:${NC}"
if [ -f ".env" ]; then
    PERM=$(stat -f "%A" .env 2>/dev/null || stat -c "%a" .env 2>/dev/null)
    if [ "$PERM" = "600" ] || [ "$PERM" = "0600" ]; then
        echo -e "${GREEN}✓${NC} .env file permissions are secure (600)"
    else
        echo -e "${RED}✗${NC} .env file permissions are insecure ($PERM). Run: chmod 600 .env"
    fi
else
    echo -e "${RED}✗${NC} .env file not found"
fi

# Check for default passwords
echo -e "\n${YELLOW}🔑 Password Security:${NC}"
if [ -f ".env" ]; then
    if grep -q "your_.*_password" .env; then
        echo -e "${RED}✗${NC} Default passwords detected in .env file"
    else
        echo -e "${GREEN}✓${NC} No default passwords found"
    fi
    
    # Check password strength (basic check)
    while IFS= read -r line; do
        if [[ $line == *"_PASS="* ]]; then
            password=$(echo "$line" | cut -d'=' -f2)
            if [ ${#password} -lt 16 ]; then
                echo -e "${YELLOW}⚠${NC}  Password shorter than 16 characters: $(echo "$line" | cut -d'=' -f1)"
            fi
        fi
    done < .env
fi

# Check network security
echo -e "\n${YELLOW}🌐 Network Security:${NC}"
if docker network ls | grep -q "services_db_network"; then
    echo -e "${GREEN}✓${NC} Custom network configured"
    
    # Check if ports are exposed only to localhost
    EXPOSED_PORTS=$(docker ps --format "table {{.Ports}}" | grep -v "PORTS" | grep -E "0\.0\.0\.0|:::")
    if [ -z "$EXPOSED_PORTS" ]; then
        echo -e "${GREEN}✓${NC} No ports exposed to all interfaces"
    else
        echo -e "${YELLOW}⚠${NC}  Some ports exposed to all interfaces:"
        echo "$EXPOSED_PORTS"
    fi
else
    echo -e "${YELLOW}⚠${NC}  Custom network not found"
fi

# Check file permissions
echo -e "\n${YELLOW}📁 File Permissions:${NC}"
if [ -d "data" ]; then
    DATA_PERM=$(stat -f "%A" data 2>/dev/null || stat -c "%a" data 2>/dev/null)
    if [ "$DATA_PERM" = "755" ] || [ "$DATA_PERM" = "0755" ]; then
        echo -e "${GREEN}✓${NC} Data directory permissions are appropriate"
    else
        echo -e "${YELLOW}⚠${NC}  Data directory permissions: $DATA_PERM"
    fi
fi

# Check for sensitive files in git
echo -e "\n${YELLOW}📝 Git Security:${NC}"
if [ -f ".gitignore" ]; then
    if grep -q ".env" .gitignore; then
        echo -e "${GREEN}✓${NC} .env file is in .gitignore"
    else
        echo -e "${RED}✗${NC} .env file not in .gitignore"
    fi
    
    if grep -q "data/" .gitignore; then
        echo -e "${GREEN}✓${NC} data/ directory is in .gitignore"
    else
        echo -e "${YELLOW}⚠${NC}  data/ directory not in .gitignore"
    fi
fi

echo -e "\n${BLUE}Security check completed!${NC}"
echo -e "${YELLOW}Recommendations:${NC}"
echo "1. Use strong passwords (16+ characters)"
echo "2. Regularly rotate passwords"
echo "3. Monitor logs for suspicious activity"
echo "4. Keep Docker images updated"
echo "5. Use SSL/TLS in production"
echo "6. Implement network firewalls"
echo "7. Regular security audits"
