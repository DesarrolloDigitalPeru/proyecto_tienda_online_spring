#!/bin/bash
# scripts/port-diagnostic.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}DIAGNÓSTICO DE PUERTOS${NC}"
echo -e "${BLUE}=========================================${NC}"

# Mostrar configuración actual
echo -e "${YELLOW}Configuración en docker-compose.yml:${NC}"
echo "----------------------------------------"
grep -A3 "ports:" docker-compose.yml | grep -v "^--" | sed 's/^/  /'

echo -e "\n${YELLOW}Puertos mapeados actualmente:${NC}"
echo "----------------------------------------"
docker-compose ps | grep -E "(app|mysql|phpmyadmin)" | awk '{print $1, $6}' | while read service ports; do
    echo "  $service: $ports"
done

echo -e "\n${YELLOW}Puertos en uso en el host:${NC}"
echo "----------------------------------------"
for port in 8081 3307 8082 8080 3306 80; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        PID=$(lsof -t -i:$port 2>/dev/null)
        PROCESS=$(ps -p $PID -o comm= 2>/dev/null | head -1)
        CONTAINER=$(docker ps --filter "publish=$port" --format "{{.Names}}" 2>/dev/null)
        
        if [ ! -z "$CONTAINER" ]; then
            echo -e "  Puerto $port: ${GREEN}USADO POR CONTENEDOR: $CONTAINER${NC}"
        else
            echo -e "  Puerto $port: ${RED}USADO POR PROCESO: $PROCESS (PID: $PID)${NC}"
        fi
    else
        echo -e "  Puerto $port: ${GREEN}DISPONIBLE${NC}"
    fi
done

echo -e "\n${YELLOW}Configuración de red:${NC}"
echo "----------------------------------------"
docker network inspect proyecto_network 2>/dev/null | grep -E '"Subnet"|"Gateway"|"Name"' | sed 's/^/  /' || echo "  Red no encontrada"

echo -e "\n${YELLOW}Recomendaciones:${NC}"
echo "----------------------------------------"

# Verificar conflictos de puertos
for port in 8081 3307 8082; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        CONTAINER=$(docker ps --filter "publish=$port" --format "{{.Names}}" 2>/dev/null)
        if [ -z "$CONTAINER" ]; then
            echo -e "  ⚠️ Puerto $port está en uso por un proceso externo"
            echo "    Para liberarlo: sudo kill -9 $(lsof -t -i:$port)"
        fi
    fi
done

echo -e "\n${BLUE}=========================================${NC}"