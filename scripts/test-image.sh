#!/bin/bash
# scripts/test-image.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}PROBANDO IMAGEN DOCKER${NC}"
echo -e "${YELLOW}=========================================${NC}"

# Limpiar contenedor de prueba anterior
docker stop test-app 2>/dev/null || true
docker rm test-app 2>/dev/null || true

# Ejecutar contenedor de prueba
echo "1. Iniciando contenedor de prueba..."
docker run -d --name test-app -p 8081:8080 proyecto-tienda:latest

echo "2. Esperando que la aplicación inicie (10 segundos)..."
sleep 10

echo "3. Verificando estado del contenedor..."
if [ "$(docker ps -q -f name=test-app)" ]; then
    echo -e "${GREEN}✅ Contenedor está corriendo${NC}"
else
    echo -e "${RED}❌ Contenedor no está corriendo${NC}"
    docker logs test-app
    exit 1
fi

echo "4. Últimos logs de la aplicación:"
docker logs test-app --tail 15

echo "5. Probando endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null || echo "000")
if [ "$HTTP_CODE" != "000" ]; then
    echo -e "${GREEN}✅ Aplicación responde (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Aplicación no responde${NC}"
fi

echo -e "\n${YELLOW}6. Limpiando contenedor de prueba...${NC}"
docker stop test-app
docker rm test-app

echo -e "${GREEN}✅ Prueba completada${NC}"