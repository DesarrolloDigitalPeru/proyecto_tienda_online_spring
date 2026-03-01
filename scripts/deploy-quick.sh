#!/bin/bash
# scripts/deploy-quick.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}DESPLIEGUE RÁPIDO${NC}"
echo -e "${YELLOW}=========================================${NC}"

# Compilar
echo "1. Compilando aplicación..."
./mvnw clean package -DskipTests

# Construir imagen
echo "2. Construyendo imagen Docker..."
docker build -t proyecto-tienda:latest .

# Desplegar
echo "3. Desplegando con docker-compose..."
docker-compose down
docker-compose up -d

# Mostrar estado
echo "4. Estado del despliegue:"
docker-compose ps

echo -e "${GREEN}✅ Aplicación disponible en: http://localhost:8081${NC}"
echo -e "${YELLOW}=========================================${NC}"