#!/bin/bash
# scripts/verify-release.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}VERIFICANDO RELEASE${NC}"
echo -e "${BLUE}=========================================${NC}"

VERSION="1.0.0"
RELEASE_DIR="release/proyecto-tienda-${VERSION}"
RELEASE_FILE="release/proyecto-tienda-${VERSION}.tar.gz"

# Verificar que existe el release
if [ ! -f "${RELEASE_FILE}" ]; then
    echo -e "${RED}❌ Archivo de release no encontrado: ${RELEASE_FILE}${NC}"
    exit 1
fi

echo -e "${YELLOW}1. Verificando integridad del archivo...${NC}"
# Verificar MD5
if [ -f "release/${RELEASE_FILE}.md5" ]; then
    cd release
    md5sum -c ${RELEASE_FILE}.md5 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Checksum MD5 válido${NC}"
    else
        echo -e "${RED}❌ Checksum MD5 inválido${NC}"
        exit 1
    fi
    cd ..
fi

echo -e "\n${YELLOW}2. Verificando estructura del release...${NC}"
# Extraer y verificar
cd release
tar -tzf ${RELEASE_FILE} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Archivo tar.gz válido${NC}"
    
    # Listar contenido
    echo "Contenido del release:"
    tar -tzf ${RELEASE_FILE} | head -10
    echo "..."
else
    echo -e "${RED}❌ Archivo tar.gz corrupto${NC}"
    exit 1
fi

# Extraer temporalmente para verificar
mkdir -p temp_verify
tar -xzf ${RELEASE_FILE} -C temp_verify

echo -e "\n${YELLOW}3. Verificando archivos críticos...${NC}"
cd temp_verify/proyecto-tienda-${VERSION}

# Verificar JAR
if [ -f *.jar ]; then
    JAR_FILE=$(ls *.jar | head -1)
    JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
    echo -e "${GREEN}✅ JAR encontrado: $JAR_FILE ($JAR_SIZE)${NC}"
else
    echo -e "${RED}❌ JAR no encontrado${NC}"
fi

# Verificar scripts
SCRIPT_COUNT=$(ls scripts/*.sh 2>/dev/null | wc -l)
if [ $SCRIPT_COUNT -ge 10 ]; then
    echo -e "${GREEN}✅ Scripts encontrados: $SCRIPT_COUNT${NC}"
else
    echo -e "${RED}❌ Scripts insuficientes: $SCRIPT_COUNT${NC}"
fi

# Verificar configuración
if [ -f "Dockerfile" ] && [ -f "docker-compose.yml" ] && [ -f "config/.env.example" ]; then
    echo -e "${GREEN}✅ Archivos de configuración OK${NC}"
else
    echo -e "${RED}❌ Faltan archivos de configuración${NC}"
fi

# Verificar documentación
if [ -f "docs/DEPLOYMENT.md" ] && [ -f "docs/README.md" ] && [ -f "VERSION.txt" ]; then
    echo -e "${GREEN}✅ Documentación completa${NC}"
else
    echo -e "${RED}❌ Falta documentación${NC}"
fi

# Verificar VERSION.txt
if [ -f "VERSION.txt" ]; then
    VERSION_CONTENT=$(grep "Versión:" VERSION.txt | head -1)
    echo -e "${GREEN}✅ ${VERSION_CONTENT}${NC}"
else
    echo -e "${RED}❌ VERSION.txt no encontrado${NC}"
fi

cd ../..

# Limpiar
rm -rf temp_verify
cd ..

echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}✅ VERIFICACIÓN COMPLETADA${NC}"
echo -e "${BLUE}=========================================${NC}"