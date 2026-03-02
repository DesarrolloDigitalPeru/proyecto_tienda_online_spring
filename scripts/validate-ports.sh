#!/bin/bash
# scripts/validate-ports.sh

echo "========================================="
echo "PUNTO 6: VALIDAR PUERTOS Y SERVICIOS"
echo "========================================="

echo "1. Verificando configuración de puertos en docker-compose.yml"
echo "----------------------------------------"

# Función para verificar puerto en docker-compose.yml
check_port_in_compose() {
    local service=$1
    local expected_port=$2
    local lines=${3:-10}
    
    echo "Servicio: $service"
    if grep -A "$lines" "^  $service:" docker-compose.yml | grep -q "$expected_port"; then
        echo "  ✅ Puerto $expected_port encontrado en docker-compose.yml"
        return 0
    else
        echo "  ⚠️  No se encontró $expected_port en docker-compose.yml (puede estar en formato diferente)"
        return 1
    fi
}

# Verificar cada servicio (usando más líneas para capturar configuración)
check_port_in_compose "mysql" "3307:3306" 15
check_port_in_compose "app" "8081:8080" 15
check_port_in_compose "phpmyadmin" "8082:80" 15

echo -e "\n2. Verificando puertos publicados (docker-compose ps)"
echo "----------------------------------------"
echo "Puertos publicados según docker-compose ps:"
docker-compose ps --format "table {{.Name}}\t{{.Ports}}" | grep -E "8081|8082|3307" || echo "⚠️  No se encontraron puertos publicados"

echo -e "\n3. Verificando disponibilidad de puertos en el host"
echo "----------------------------------------"

# Verificar puertos accesibles desde host
for port in 8081 8082 3307; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$port 2>/dev/null | grep -q "200\|302\|401\|403"; then
        echo "Puerto $port: ✅ Respondiendo (HTTP $(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port 2>/dev/null))"
    elif nc -zv localhost $port 2>/dev/null; then
        echo "Puerto $port: ✅ Abierto (no HTTP)"
    else
        # Verificar si el puerto está en uso por Docker aunque no responda HTTP
        if docker-compose ps | grep -q "0.0.0.0:$port->"; then
            echo "Puerto $port: ✅ Expuesto por Docker (puede no responder HTTP)"
        else
            echo "Puerto $port: ❌ No accesible"
        fi
    fi
done

echo -e "\n4. Verificando conectividad entre servicios"
echo "----------------------------------------"

# Verificar redes
NETWORK_NAME=$(docker network ls --filter name=proyecto --format "{{.Name}}" | head -1)
if [ -n "$NETWORK_NAME" ]; then
    echo "✅ Red encontrada: $NETWORK_NAME"
    
    # Listar contenedores en la red
    echo "Contenedores en la red:"
    docker network inspect "$NETWORK_NAME" --format '{{range .Containers}}{{.Name}} {{end}}' | tr ' ' '\n' | sed 's/^/  - /'
else
    echo "❌ No se encontró red 'proyecto'"
fi

# Verificar dependencias
echo -e "\nDependencias configuradas:"
if grep -A 5 "^  app:" docker-compose.yml | grep -q "depends_on"; then
    echo "  ✅ app depende de mysql"
else
    echo "  ⚠️  app no tiene depends_on explícito"
fi

if grep -A 5 "^  phpmyadmin:" docker-compose.yml | grep -q "depends_on"; then
    echo "  ✅ phpmyadmin depende de mysql"
else
    echo "  ⚠️  phpmyadmin no tiene depends_on explícito"
fi

echo -e "\n========================================="
echo "✅ VALIDACIÓN DE PUERTOS COMPLETADA"
echo "========================================="
