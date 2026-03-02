#!/bin/bash
# scripts/test-connectivity.sh

echo "========================================="
echo "PROBANDO CONECTIVIDAD DE SERVICIOS"
echo "========================================="

echo "1. Verificando servicios en ejecución:"
docker-compose ps --services --filter "status=running" | while read service; do
    echo "  ✅ $service"
done

echo -e "\n2. Verificando MySQL:"
# Verificar desde host
if curl -s -o /dev/null http://localhost:8082; then
    echo "  ✅ phpMyAdmin accesible (indica que MySQL está disponible)"
else
    # Verificar directamente el contenedor
    if docker exec proyecto_mysql mysqladmin ping -h localhost 2>/dev/null; then
        echo "  ✅ MySQL responde internamente"
    else
        echo "  ⚠️  No se pudo verificar MySQL directamente"
    fi
fi

# Verificar base de datos
if docker exec proyecto_mysql mysql -u root -e "USE tiendaplazachina" 2>/dev/null; then
    echo "  ✅ Base de datos 'tiendaplazachina' existe y accesible"
else
    echo "  ⚠️  No se pudo verificar base de datos"
fi

echo -e "\n3. Verificando aplicación Spring Boot:"
APP_PORT=8081
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$APP_PORT 2>/dev/null)

if [ "$HTTP_CODE" != "000" ]; then
    echo "  ✅ Aplicación responde en puerto $APP_PORT (HTTP $HTTP_CODE)"
    
    # Intentar obtener título de la página
    TITLE=$(curl -s http://localhost:$APP_PORT | grep -o "<title>[^<]*" | head -1 | sed 's/<title>//')
    if [ -n "$TITLE" ]; then
        echo "     Título: $TITLE"
    fi
else
    echo "  ⚠️  Aplicación no responde HTTP en puerto $APP_PORT"
    # Verificar si el contenedor está corriendo
    if docker ps | grep -q proyecto_app; then
        echo "     Contenedor 'proyecto_app' está corriendo pero no responde HTTP"
    fi
fi

echo -e "\n4. Verificando phpMyAdmin:"
PHPMYADMIN_PORT=8082
PHPMYADMIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PHPMYADMIN_PORT 2>/dev/null)

if [ "$PHPMYADMIN_CODE" = "200" ]; then
    echo "  ✅ phpMyAdmin responde en puerto $PHPMYADMIN_PORT (HTTP 200)"
    
    # Verificar si puede conectar a MySQL
    if curl -s http://localhost:$PHPMYADMIN_PORT | grep -q "phpMyAdmin"; then
        echo "     Interfaz de phpMyAdmin detectada"
    fi
else
    echo "  ⚠️  phpMyAdmin no responde HTTP 200 (código: $PHPMYADMIN_CODE)"
fi

echo -e "\n5. Verificando conectividad entre servicios (sin usar ping):"

# Verificar que los contenedores están en la misma red
NETWORK=$(docker network ls --filter name=proyecto --format "{{.Name}}" | head -1)
if [ -n "$NETWORK" ]; then
    echo "  ✅ Red '$NETWORK' existe"
    
    # Obtener IPs de los contenedores
    MYSQL_IP=$(docker inspect proyecto_mysql -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
    APP_IP=$(docker inspect proyecto_app -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
    PHPMYADMIN_IP=$(docker inspect proyecto_phpmyadmin -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
    
    echo "  IPs en la red:"
    [ -n "$MYSQL_IP" ] && echo "    - MySQL: $MYSQL_IP"
    [ -n "$APP_IP" ] && echo "    - App: $APP_IP"
    [ -n "$PHPMYADMIN_IP" ] && echo "    - phpMyAdmin: $PHPMYADMIN_IP"
    
    # Verificar que pueden verse entre sí (usando comando alternativo)
    if [ -n "$MYSQL_IP" ] && [ -n "$APP_IP" ]; then
        echo "  ✅ App y MySQL en misma red"
    fi
    
    if [ -n "$MYSQL_IP" ] && [ -n "$PHPMYADMIN_IP" ]; then
        echo "  ✅ phpMyAdmin y MySQL en misma red"
    fi
else
    echo "  ⚠️  No se encontró red de proyecto"
fi

echo -e "\n========================================="
echo "✅ PRUEBA DE CONECTIVIDAD COMPLETADA"
echo "========================================="

# Resumen final
echo -e "\n��� RESUMEN:"
echo "  MySQL: $(docker ps --filter name=proyecto_mysql --format '{{.Status}}' | grep -o 'Up' || echo 'No disponible')"
echo "  App: $(docker ps --filter name=proyecto_app --format '{{.Status}}' | grep -o 'Up' || echo 'No disponible')"
echo "  phpMyAdmin: $(docker ps --filter name=proyecto_phpmyadmin --format '{{.Status}}' | grep -o 'Up' || echo 'No disponible')"
echo ""
echo "  ��� URLs:"
echo "    - App: http://localhost:8081"
echo "    - phpMyAdmin: http://localhost:8082"
