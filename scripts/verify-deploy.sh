#!/bin/bash
# scripts/verify-deploy.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}VERIFICANDO DESPLIEGUE${NC}"
echo -e "${YELLOW}=========================================${NC}"

# 1. Verificar contenedores
echo "1. Verificando contenedores en ejecución:"
RUNNING=$(docker-compose ps --services --filter "status=running" | wc -l)
TOTAL=$(docker-compose ps --services | wc -l)

if [ "$RUNNING" -eq "$TOTAL" ]; then
    echo -e "${GREEN}✅ Todos los contenedores están en ejecución ($RUNNING/$TOTAL)${NC}"
else
    echo -e "${RED}❌ Solo $RUNNING de $TOTAL contenedores están en ejecución${NC}"
    docker-compose ps
fi

# 2. Verificar MySQL
echo -e "\n2. Verificando MySQL:"
if docker exec proyecto_mysql mysqladmin ping -h localhost -u root --silent 2>/dev/null; then
    echo -e "${GREEN}✅ MySQL está funcionando${NC}"
    
    # Verificar base de datos
    DB_EXISTS=$(docker exec proyecto_mysql mysql -u root -e "SHOW DATABASES LIKE 'tiendaplazachina';" 2>/dev/null | grep -c "tiendaplazachina")
    if [ "$DB_EXISTS" -gt 0 ]; then
        echo -e "${GREEN}✅ Base de datos 'tiendaplazachina' existe${NC}"
    else
        echo -e "${RED}❌ Base de datos 'tiendaplazachina' no existe${NC}"
    fi
else
    echo -e "${RED}❌ MySQL no responde${NC}"
fi

# 3. Verificar aplicación
echo -e "\n3. Verificando aplicación Spring Boot:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null || echo "000")
if [ "$HTTP_CODE" != "000" ]; then
    echo -e "${GREEN}✅ Aplicación responde (HTTP $HTTP_CODE)${NC}"
    
    # Verificar conexión a BD (si tiene endpoint de health)
    HEALTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/actuator/health 2>/dev/null || echo "000")
    if [ "$HEALTH_CODE" = "200" ]; then
        echo -e "${GREEN}✅ Health check OK${NC}"
    fi
else
    echo -e "${RED}❌ Aplicación no responde${NC}"
fi

# 4. Verificar phpMyAdmin
echo -e "\n4. Verificando phpMyAdmin:"
PMA_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082 2>/dev/null || echo "000")
if [ "$PMA_CODE" = "200" ]; then
    echo -e "${GREEN}✅ phpMyAdmin responde${NC}"
else
    echo -e "${RED}❌ phpMyAdmin no responde (HTTP $PMA_CODE)${NC}"
fi

# 5. Verificar logs sin errores
echo -e "\n5. Verificando logs (últimas 20 líneas sin errores críticos):"
ERRORS=$(docker-compose logs --tail=50 app 2>/dev/null | grep -i "error\|exception\|failed" | tail -5)
if [ -z "$ERRORS" ]; then
    echo -e "${GREEN}✅ No se encontraron errores críticos en logs recientes${NC}"
else
    echo -e "${RED}⚠️ Se encontraron errores:${NC}"
    echo "$ERRORS"
fi

echo -e "\n${YELLOW}=========================================${NC}"
echo -e "${GREEN}VERIFICACIÓN COMPLETADA${NC}"
echo -e "${YELLOW}=========================================${NC}"