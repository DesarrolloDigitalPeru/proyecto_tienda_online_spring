#!/bin/bash
# scripts/validate-system.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}PUNTO 7: VALIDAR EJECUCIÓN DEL SISTEMA${NC}"
echo -e "${BLUE}=========================================${NC}"

# Contador de pruebas
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Función para ejecutar prueba
run_test() {
    TEST_NAME=$1
    TEST_COMMAND=$2
    EXPECTED_RESULT=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${YELLOW}Prueba $TOTAL_TESTS: $TEST_NAME${NC}"
    echo "----------------------------------------"
    
    if eval $TEST_COMMAND; then
        if [ "$EXPECTED_RESULT" = "success" ]; then
            echo -e "${GREEN}✅ PASÓ: $TEST_NAME${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ FALLÓ: Se esperaba fallo pero tuvo éxito${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        if [ "$EXPECTED_RESULT" = "fail" ]; then
            echo -e "${GREEN}✅ PASÓ (fallo esperado): $TEST_NAME${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ FALLÓ: $TEST_NAME${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
}

# 1. VALIDAR REQUISITOS DEL SISTEMA
echo -e "\n${PURPLE}📋 1. VALIDANDO REQUISITOS DEL SISTEMA${NC}"

# 1.1 Verificar Docker
run_test "Docker instalado" "command -v docker" "success"

# 1.2 Verificar Docker Compose
run_test "Docker Compose instalado" "command -v docker-compose" "success"

# 1.3 Verificar Java (opcional)
run_test "Java instalado (opcional)" "command -v java" "success"

# 1.4 Verificar Maven Wrapper
run_test "Maven Wrapper existe" "[ -f 'mvnw' ]" "success"

# 2. VALIDAR ARCHIVOS DE CONFIGURACIÓN
echo -e "\n${PURPLE}📄 2. VALIDANDO ARCHIVOS DE CONFIGURACIÓN${NC}"

# 2.1 Verificar Dockerfile
run_test "Dockerfile existe" "[ -f 'Dockerfile' ]" "success"

# 2.2 Verificar docker-compose.yml
run_test "docker-compose.yml existe" "[ -f 'docker-compose.yml' ]" "success"

# 2.3 Verificar .env.example
run_test ".env.example existe" "[ -f '.env.example' ]" "success"

# 2.4 Verificar estructura de directorios
run_test "Directorios básicos existen" "[ -d 'src' ] && [ -d 'target' ]" "success"

# 3. VALIDAR SERVICIOS EN EJECUCIÓN
echo -e "\n${PURPLE}🚀 3. VALIDANDO SERVICIOS EN EJECUCIÓN${NC}"

# 3.1 Verificar que los servicios están levantados
run_test "Servicios Docker están corriendo" "docker-compose ps --services --filter 'status=running' | grep -q ." "success"

# 3.2 Verificar servicio MySQL
run_test "Servicio MySQL está running" "docker-compose ps mysql | grep -q 'Up'" "success"

# 3.3 Verificar servicio App
run_test "Servicio App está running" "docker-compose ps app | grep -q 'Up'" "success"

# 3.4 Verificar servicio phpMyAdmin
run_test "Servicio phpMyAdmin está running" "docker-compose ps phpmyadmin | grep -q 'Up'" "success"

# 4. VALIDAR PUERTOS
echo -e "\n${PURPLE}🔌 4. VALIDANDO PUERTOS${NC}"

# 4.1 Verificar puerto MySQL (3307)
run_test "Puerto MySQL 3307 accesible" "nc -z localhost 3307" "success"

# 4.2 Verificar puerto App (8081)
run_test "Puerto App 8081 accesible" "nc -z localhost 8081" "success"

# 4.3 Verificar puerto phpMyAdmin (8082)
run_test "Puerto phpMyAdmin 8082 accesible" "nc -z localhost 8082" "success"

# 5. VALIDAR CONECTIVIDAD
echo -e "\n${PURPLE}🌐 5. VALIDANDO CONECTIVIDAD${NC}"

# 5.1 Verificar que MySQL responde
run_test "MySQL responde a ping" "docker exec proyecto_mysql mysqladmin ping -h localhost -u root --silent" "success"

# 5.2 Verificar base de datos tiendaplazachina
run_test "Base de datos tiendaplazachina existe" "docker exec proyecto_mysql mysql -u root -e 'SHOW DATABASES;' 2>/dev/null | grep -q 'tiendaplazachina'" "success"

# 5.3 Verificar que App responde HTTP
run_test "App responde HTTP" "curl -s -o /dev/null -w '%{http_code}' http://localhost:8081 | grep -q '200\|404\|302'" "success"

# 5.4 Verificar que phpMyAdmin responde
run_test "phpMyAdmin responde HTTP" "curl -s -o /dev/null -w '%{http_code}' http://localhost:8082 | grep -q '200\|302'" "success"

# 5.5 Verificar conectividad App → MySQL
run_test "App puede conectar a MySQL" "docker exec proyecto_app nc -z mysql 3306" "success"

# 5.6 Verificar conectividad phpMyAdmin → MySQL
run_test "phpMyAdmin puede conectar a MySQL" "docker exec proyecto_phpmyadmin nc -z mysql 3306" "success"

# 6. VALIDAR LOGS
echo -e "\n${PURPLE}📝 6. VALIDANDO LOGS${NC}"

# 6.1 Verificar logs de MySQL sin errores críticos
run_test "Logs MySQL sin errores críticos" "! docker logs proyecto_mysql 2>&1 | grep -qi 'error\|fatal'" "success"

# 6.2 Verificar logs de App sin errores críticos
run_test "Logs App sin errores críticos" "! docker logs proyecto_app 2>&1 | grep -qi 'exception\|error\|failed'" "success"

# 6.3 Verificar logs de phpMyAdmin sin errores críticos
run_test "Logs phpMyAdmin sin errores críticos" "! docker logs proyecto_phpmyadmin 2>&1 | grep -qi 'error\|fatal'" "success"

# 7. VALIDAR PERSISTENCIA
echo -e "\n${PURPLE}💾 7. VALIDANDO PERSISTENCIA${NC}"

# 7.1 Verificar volumen de MySQL
run_test "Volumen MySQL existe" "docker volume ls | grep -q 'mysql_data'" "success"

# 7.2 Verificar que el volumen tiene datos
run_test "Volumen MySQL tiene datos" "docker run --rm -v mysql_data:/data alpine ls -la /data/ | grep -q 'mysql'" "success"

# 8. VALIDAR RENDIMIENTO
echo -e "\n${PURPLE}⚡ 8. VALIDANDO RENDIMIENTO${NC}"

# 8.1 Medir tiempo de respuesta de App
echo "Midiendo tiempo de respuesta de App..."
RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}\n' http://localhost:8081 2>/dev/null || echo "999")
if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
    echo -e "${GREEN}✅ Tiempo de respuesta: ${RESPONSE_TIME}s (aceptable)${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ Tiempo de respuesta: ${RESPONSE_TIME}s (lento)${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 9. MOSTRAR RESUMEN
echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}📊 RESUMEN DE VALIDACIÓN${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Total pruebas: ${YELLOW}$TOTAL_TESTS${NC}"
echo -e "${GREEN}✅ Pasadas: $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}❌ Falladas: $FAILED_TESTS${NC}"
else
    echo -e "${GREEN}✅ Falladas: $FAILED_TESTS${NC}"
fi

# Calcular porcentaje de éxito
SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo -e "Tasa de éxito: ${YELLOW}${SUCCESS_RATE}%${NC}"

echo -e "\n${BLUE}=========================================${NC}"
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ SISTEMA VALIDADO CORRECTAMENTE${NC}"
else
    echo -e "${RED}❌ HAY $FAILED_TESTS PRUEBAS FALLADAS${NC}"
fi
echo -e "${BLUE}=========================================${NC}"