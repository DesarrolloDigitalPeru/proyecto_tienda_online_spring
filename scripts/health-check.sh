#!/bin/bash
# scripts/health-check.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}HEALTH CHECK DETALLADO${NC}"
echo -e "${BLUE}=========================================${NC}"

# Función para health check de MySQL
check_mysql() {
    echo -e "\n${YELLOW}🔍 MySQL Health Check:${NC}"
    
    # Verificar proceso
    if docker ps --filter "name=proyecto_mysql" --filter "status=running" | grep -q "proyecto_mysql"; then
        echo -e "  ${GREEN}✅ Proceso: En ejecución${NC}"
    else
        echo -e "  ${RED}❌ Proceso: No ejecutándose${NC}"
        return 1
    fi
    
    # Verificar ping
    if docker exec proyecto_mysql mysqladmin ping -h localhost -u root --silent 2>/dev/null; then
        echo -e "  ${GREEN}✅ Ping: Responde${NC}"
    else
        echo -e "  ${RED}❌ Ping: No responde${NC}"
    fi
    
    # Verificar base de datos
    if docker exec proyecto_mysql mysql -u root -e "SHOW DATABASES;" 2>/dev/null | grep -q "tiendaplazachina"; then
        echo -e "  ${GREEN}✅ BD tiendaplazachina: Existe${NC}"
    else
        echo -e "  ${RED}❌ BD tiendaplazachina: No existe${NC}"
    fi
    
    # Verificar conexiones
    CONNECTIONS=$(docker exec proyecto_mysql mysql -u root -e "SHOW PROCESSLIST;" 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✅ Conexiones activas: $((CONNECTIONS - 2))${NC}"
    
    # Verificar uptime
    UPTIME=$(docker exec proyecto_mysql mysql -u root -e "SHOW STATUS LIKE 'Uptime';" 2>/dev/null | grep "Uptime" | awk '{print $2}')
    if [ ! -z "$UPTIME" ]; then
        UPTIME_HOURS=$((UPTIME / 3600))
        UPTIME_MIN=$(((UPTIME % 3600) / 60))
        echo -e "  ${GREEN}✅ Uptime: ${UPTIME_HOURS}h ${UPTIME_MIN}m${NC}"
    fi
}

# Función para health check de App
check_app() {
    echo -e "\n${YELLOW}🔍 App Spring Boot Health Check:${NC}"
    
    # Verificar proceso
    if docker ps --filter "name=proyecto_app" --filter "status=running" | grep -q "proyecto_app"; then
        echo -e "  ${GREEN}✅ Proceso: En ejecución${NC}"
    else
        echo -e "  ${RED}❌ Proceso: No ejecutándose${NC}"
        return 1
    fi
    
    # Verificar HTTP
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" != "000" ]; then
        echo -e "  ${GREEN}✅ HTTP: Responde (código $HTTP_CODE)${NC}"
    else
        echo -e "  ${RED}❌ HTTP: No responde${NC}"
    fi
    
    # Verificar health endpoint si existe
    HEALTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/actuator/health 2>/dev/null || echo "000")
    if [ "$HEALTH_CODE" = "200" ]; then
        HEALTH_DATA=$(curl -s http://localhost:8081/actuator/health)
        STATUS=$(echo $HEALTH_DATA | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        echo -e "  ${GREEN}✅ Health endpoint: $STATUS${NC}"
    elif [ "$HEALTH_CODE" != "000" ]; then
        echo -e "  ${YELLOW}⚠️ Health endpoint: Código $HEALTH_CODE${NC}"
    else
        echo -e "  ${YELLOW}⚠️ Health endpoint: No disponible${NC}"
    fi
    
    # Verificar uso de memoria
    MEM_USAGE=$(docker stats proyecto_app --no-stream --format "{{.MemUsage}}" | cut -d'/' -f1)
    echo -e "  ${GREEN}✅ Memoria usada: $MEM_USAGE${NC}"
    
    # Verificar logs recientes
    RECENT_ERRORS=$(docker logs proyecto_app --tail 20 2>&1 | grep -i "error\|exception" | tail -3)
    if [ -z "$RECENT_ERRORS" ]; then
        echo -e "  ${GREEN}✅ Logs: Sin errores recientes${NC}"
    else
        echo -e "  ${RED}❌ Logs: Se encontraron errores${NC}"
        echo "$RECENT_ERRORS" | sed 's/^/     /'
    fi
}

# Función para health check de phpMyAdmin
check_phpmyadmin() {
    echo -e "\n${YELLOW}🔍 phpMyAdmin Health Check:${NC}"
    
    # Verificar proceso
    if docker ps --filter "name=proyecto_phpmyadmin" --filter "status=running" | grep -q "proyecto_phpmyadmin"; then
        echo -e "  ${GREEN}✅ Proceso: En ejecución${NC}"
    else
        echo -e "  ${RED}❌ Proceso: No ejecutándose${NC}"
        return 1
    fi
    
    # Verificar HTTP
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "  ${GREEN}✅ HTTP: Responde (código $HTTP_CODE)${NC}"
    else
        echo -e "  ${RED}❌ HTTP: No responde correctamente${NC}"
    fi
    
    # Verificar conexión a MySQL
    if docker logs proyecto_phpmyadmin 2>&1 | grep -q "Connected to MySQL"; then
        echo -e "  ${GREEN}✅ Conexión MySQL: Establecida${NC}"
    else
        LOGS=$(docker logs proyecto_phpmyadmin --tail 5 2>&1)
        if echo "$LOGS" | grep -q "Connection refused"; then
            echo -e "  ${RED}❌ Conexión MySQL: Rechazada${NC}"
        else
            echo -e "  ${YELLOW}⚠️ Conexión MySQL: No verificada${NC}"
        fi
    fi
}

# Función para verificar recursos del sistema
check_resources() {
    echo -e "\n${YELLOW}🔍 Recursos del Sistema:${NC}"
    
    # CPU
    CPU_USAGE=$(docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}" | grep -v "NAME")
    echo -e "  CPU Usage:"
    echo "$CPU_USAGE" | sed 's/^/    /'
    
    # Memoria
    MEM_USAGE=$(docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep -v "NAME")
    echo -e "  Memoria Usage:"
    echo "$MEM_USAGE" | sed 's/^/    /'
    
    # Red
    NET_IO=$(docker stats --no-stream --format "table {{.Name}}\t{{.NetIO}}" | grep -v "NAME")
    echo -e "  Red I/O:"
    echo "$NET_IO" | sed 's/^/    /'
}

# Ejecutar health checks
check_mysql
check_app
check_phpmyadmin
check_resources

echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}✅ HEALTH CHECK COMPLETADO${NC}"
echo -e "${BLUE}=========================================${NC}"