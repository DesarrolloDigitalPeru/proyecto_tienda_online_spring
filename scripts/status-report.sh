#!/bin/bash
# scripts/status-report.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}📊 REPORTE DE ESTADO DEL SISTEMA${NC}"
echo -e "${BLUE}=========================================${NC}"
echo "Fecha: $(date)"
echo "Host: $(hostname)"
echo -e "${BLUE}=========================================${NC}"

# 1. Versiones
echo -e "\n${YELLOW}📌 VERSIONES:${NC}"
echo "  Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
echo "  Docker Compose: $(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)"
echo "  Java: $(java -version 2>&1 | head -n1 | cut -d'"' -f2)"
echo "  Maven: $(./mvnw --version 2>/dev/null | head -n1 | cut -d' ' -f3 || echo 'No disponible')"

# 2. Contenedores
echo -e "\n${YELLOW}📦 CONTENEDORES:${NC}"
docker-compose ps --services | while read service; do
    STATUS=$(docker-compose ps $service --format "table {{.Status}}" | tail -n1)
    if echo "$STATUS" | grep -q "Up"; then
        echo -e "  ${GREEN}✅ $service: $STATUS${NC}"
    else
        echo -e "  ${RED}❌ $service: $STATUS${NC}"
    fi
done

# 3. Puertos
echo -e "\n${YELLOW}🔌 PUERTOS:${NC}"
for port in 8081 3307 8082; do
    if nc -z localhost $port 2>/dev/null; then
        SERVICE=""
        if [ "$port" = "8081" ]; then SERVICE="App"; fi
        if [ "$port" = "3307" ]; then SERVICE="MySQL"; fi
        if [ "$port" = "8082" ]; then SERVICE="phpMyAdmin"; fi
        echo -e "  ${GREEN}✅ Puerto $port ($SERVICE): Abierto${NC}"
    else
        echo -e "  ${RED}❌ Puerto $port: Cerrado${NC}"
    fi
done

# 4. Logs recientes
echo -e "\n${YELLOW}📝 ÚLTIMOS EVENTOS:${NC}"
echo "  MySQL: $(docker logs proyecto_mysql --tail 1 2>&1 | head -c 80)..."
echo "  App: $(docker logs proyecto_app --tail 1 2>&1 | head -c 80)..."
echo "  phpMyAdmin: $(docker logs proyecto_phpmyadmin --tail 1 2>&1 | head -c 80)..."

# 5. Uptime
echo -e "\n${YELLOW}⏱️  UPTIME:${NC}"
for service in mysql app phpmyadmin; do
    CREATED=$(docker inspect proyecto_$service --format='{{.Created}}' 2>/dev/null | cut -d'T' -f1)
    if [ ! -z "$CREATED" ]; then
        echo "  $service: Desde $CREATED"
    fi
done

# 6. Resumen rápido
echo -e "\n${YELLOW}📋 RESUMEN:${NC}"
RUNNING=$(docker-compose ps --services --filter "status=running" | wc -l)
TOTAL=$(docker-compose ps --services | wc -l)
echo "  Servicios: $RUNNING/$TOTAL en ejecución"

# 7. Recomendaciones
echo -e "\n${YELLOW}💡 RECOMENDACIONES:${NC}"
if [ $RUNNING -lt $TOTAL ]; then
    echo "  ⚠️ Hay servicios caídos. Ejecuta: docker-compose up -d"
fi
if ! nc -z localhost 8081 2>/dev/null; then
    echo "  ⚠️ App no responde. Verifica logs: docker-compose logs app"
fi

echo -e "\n${BLUE}=========================================${NC}"