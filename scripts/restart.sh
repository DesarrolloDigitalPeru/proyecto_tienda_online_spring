#!/bin/bash
# scripts/restart.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}REINICIANDO SERVICIOS${NC}"
echo -e "${YELLOW}=========================================${NC}"

# Reiniciar servicios
echo "Reiniciando contenedores..."
docker-compose restart

echo "Esperando 10 segundos..."
sleep 10

# Mostrar estado
echo -e "\nEstado después del reinicio:"
docker-compose ps

echo -e "\n${GREEN}✅ Servicios reiniciados${NC}"
echo -e "${YELLOW}=========================================${NC}"