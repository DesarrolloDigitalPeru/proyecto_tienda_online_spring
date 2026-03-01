#!/bin/bash
# scripts/build-images.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}PUNTO 4: CONSTRUIR IMÁGENES DE LA APLICACIÓN${NC}"
echo -e "${BLUE}=========================================${NC}"

# Fecha para tags
DATE_TAG=$(date +%Y%m%d)
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")
VERSION="1.0.0"

echo -e "${YELLOW}1. Limpiando contenedores anteriores...${NC}"
docker-compose down 2>/dev/null || true

echo -e "\n${YELLOW}2. Compilando aplicación con Maven...${NC}"
./mvnw clean package -DskipTests

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error en la compilación${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Compilación exitosa${NC}"

echo -e "\n${YELLOW}3. Construyendo imagen de la aplicación...${NC}"
echo "Tags a crear:"
echo "  - proyecto-tienda:latest"
echo "  - proyecto-tienda:${DATE_TAG}"
echo "  - proyecto-tienda:${COMMIT_HASH}"
echo "  - proyecto-tienda:${VERSION}"

# Construir imagen con diferentes tags
docker build -t proyecto-tienda:latest \
             -t proyecto-tienda:${DATE_TAG} \
             -t proyecto-tienda:${COMMIT_HASH} \
             -t proyecto-tienda:${VERSION} \
             . --no-cache

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Imagen construida exitosamente${NC}"
else
    echo -e "${RED}❌ Error construyendo imagen${NC}"
    exit 1
fi

echo -e "\n${YELLOW}4. Imágenes creadas:${NC}"
docker images | grep proyecto-tienda

echo -e "\n${YELLOW}5. Información de la imagen:${NC}"
docker inspect proyecto-tienda:latest | grep -E '"Created"|"Size"' | head -2

echo -e "\n${YELLOW}6. Verificando capas de la imagen:${NC}"
docker history proyecto-tienda:latest | head -10

echo -e "\n${YELLOW}7. Guardando imagen como archivo tar...${NC}"
docker save proyecto-tienda:latest | gzip > proyecto-tienda-${DATE_TAG}.tar.gz
echo -e "${GREEN}✅ Imagen guardada: proyecto-tienda-${DATE_TAG}.tar.gz${NC}"

echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}✅ CONSTRUCCIÓN COMPLETADA${NC}"
echo -e "${BLUE}=========================================${NC}"
echo "Para probar la imagen ejecuta:"
echo "  docker run -d -p 8081:8080 --name test-app proyecto-tienda:latest"
echo "  docker logs -f test-app"
echo -e "${BLUE}=========================================${NC}"