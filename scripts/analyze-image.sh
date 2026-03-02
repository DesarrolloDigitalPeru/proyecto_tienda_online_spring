#!/bin/bash
# scripts/analyze-image.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}ANALIZANDO IMAGEN DOCKER${NC}"
echo -e "${YELLOW}=========================================${NC}"

# Obtener tamaño
SIZE=$(docker inspect proyecto-tienda:latest | grep -m1 "Size" | cut -d ':' -f2 | tr -d ' ,')
SIZE_MB=$((SIZE / 1024 / 1024))

echo -e "Tamaño de imagen: ${YELLOW}${SIZE_MB}MB${NC}"

if [ $SIZE_MB -gt 500 ]; then
    echo -e "${RED}⚠️ La imagen es grande (>500MB)${NC}"
    echo "Recomendaciones para optimizar:"
    echo "  - Usar Alpine Linux como base (ya implementado)"
    echo "  - Limpiar caché de Maven en el build"
    echo "  - Usar multi-stage build (recomendado)"
elif [ $SIZE_MB -gt 300 ]; then
    echo -e "${YELLOW}⚠️ Tamaño aceptable pero mejorable${NC}"
else
    echo -e "${GREEN}✅ Tamaño de imagen óptimo${NC}"
fi

echo -e "\n${YELLOW}Capas de la imagen:${NC}"
docker history proyecto-tienda:latest --format "table {{.CreatedSince}}\t{{.Size}}\t{{.CreatedBy}}" | head -10

echo -e "\n${YELLOW}Paquetes instalados (si es Alpine):${NC}"
docker run --rm --entrypoint sh proyecto-tienda:latest -c "apk list --installed 2>/dev/null || echo 'No es Alpine o no tiene apk'"