#!/bin/bash
# scripts/deploy.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}PUNTO 5: DESPLEGAR LA APLICACIÓN${NC}"
echo -e "${BLUE}=========================================${NC}"

# Verificar Docker y Docker Compose
echo -e "${YELLOW}1. Verificando requisitos...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker: $(docker --version)${NC}"
echo -e "${GREEN}✅ Docker Compose: $(docker-compose --version)${NC}"

# Verificar puertos disponibles
echo -e "\n${YELLOW}2. Verificando puertos...${NC}"
for port in 8081 3307 8082; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${RED}❌ Puerto $port está en uso${NC}"
        echo "   Proceso usando el puerto:"
        lsof -i :$port
        exit 1
    else
        echo -e "${GREEN}✅ Puerto $port disponible${NC}"
    fi
done

# Verificar que existe el JAR
echo -e "\n${YELLOW}3. Verificando archivo JAR...${NC}"
if ls target/*.jar 1> /dev/null 2>&1; then
    JAR_FILE=$(ls target/*.jar | head -1)
    echo -e "${GREEN}✅ JAR encontrado: $(basename $JAR_FILE)${NC}"
else
    echo -e "${YELLOW}⚠️ JAR no encontrado. Compilando...${NC}"
    ./mvnw clean package -DskipTests
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al compilar${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Compilación exitosa${NC}"
fi

# Construir imagen actualizada
echo -e "\n${YELLOW}4. Construyendo imagen Docker...${NC}"
docker build -t proyecto-tienda:deploy-$(date +%Y%m%d-%H%M%S) -t proyecto-tienda:latest .

# Verificar que docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ docker-compose.yml no encontrado${NC}"
    exit 1
fi

# Detener servicios anteriores si existen
echo -e "\n${YELLOW}5. Deteniendo servicios anteriores...${NC}"
docker-compose down --remove-orphans

# Levantar servicios con docker-compose
echo -e "\n${YELLOW}6. Desplegando servicios...${NC}"
docker-compose up -d

# Esperar a que los servicios inicien
echo -e "\n${YELLOW}7. Esperando inicialización (20 segundos)...${NC}"
sleep 20

# Verificar estado de los servicios
echo -e "\n${YELLOW}8. Estado de los servicios:${NC}"
docker-compose ps

# Verificar logs de la aplicación
echo -e "\n${YELLOW}9. Últimos logs de la aplicación:${NC}"
docker-compose logs --tail=20 app

# Verificar salud de MySQL
echo -e "\n${YELLOW}10. Verificando conexión a MySQL...${NC}"
if docker exec proyecto_mysql mysqladmin ping -h localhost -u root --silent 2>/dev/null; then
    echo -e "${GREEN}✅ MySQL está funcionando${NC}"
    
    # Mostrar bases de datos
    echo -e "\nBases de datos disponibles:"
    docker exec proyecto_mysql mysql -u root -e "SHOW DATABASES;" 2>/dev/null | grep -v "Database"
else
    echo -e "${RED}❌ MySQL no responde${NC}"
    docker-compose logs mysql --tail=20
fi

# Probar endpoint de la aplicación
echo -e "\n${YELLOW}11. Probando aplicación...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null || echo "000")
if [ "$HTTP_CODE" != "000" ]; then
    echo -e "${GREEN}✅ Aplicación responde (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Aplicación no responde${NC}"
fi

echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}✅ DESPLIEGUE COMPLETADO${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "📱 Aplicación: ${GREEN}http://localhost:8081${NC}"
echo -e "🗄️  phpMyAdmin: ${GREEN}http://localhost:8082${NC}"
echo -e "🛢️  MySQL: ${GREEN}localhost:3307${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Para ver logs: ${YELLOW}docker-compose logs -f${NC}"
echo -e "Para detener: ${YELLOW}docker-compose down${NC}"
echo -e "Para reiniciar: ${YELLOW}docker-compose restart${NC}"
echo -e "${BLUE}=========================================${NC}"