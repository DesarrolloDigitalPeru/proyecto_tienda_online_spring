#!/bin/bash
# scripts/release-version.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}PUNTO 9: PREPARAR VERSIÓN FINAL${NC}"
echo -e "${BLUE}=========================================${NC}"

# Configuración de versión
VERSION="1.0.0"
RELEASE_DATE=$(date +%Y%m%d)
RELEASE_DIR="release/proyecto-tienda-${VERSION}"
RELEASE_FILE="proyecto-tienda-${VERSION}.tar.gz"

echo -e "${YELLOW}📦 Preparando versión final ${VERSION}${NC}"
echo "Fecha de release: ${RELEASE_DATE}"
echo "Directorio release: ${RELEASE_DIR}"
echo -e "${BLUE}=========================================${NC}"

# 1. Verificar que estamos en la rama correcta
echo -e "\n${YELLOW}1. Verificando rama de release...${NC}"
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo -e "${GREEN}✅ Rama correcta: $CURRENT_BRANCH${NC}"
else
    echo -e "${RED}❌ Debes estar en main/master para release. Rama actual: $CURRENT_BRANCH${NC}"
    exit 1
fi

# 2. Verificar que no hay cambios sin commit
echo -e "\n${YELLOW}2. Verificando cambios sin commit...${NC}"
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${GREEN}✅ Working directory limpio${NC}"
else
    echo -e "${RED}❌ Hay cambios sin commit. Commitear o stash antes de release${NC}"
    git status --porcelain
    exit 1
fi

# 3. Ejecutar pruebas completas
echo -e "\n${YELLOW}3. Ejecutar suite completa de pruebas...${NC}"
./mvnw clean test
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Las pruebas fallaron. Abortando release${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Pruebas exitosas${NC}"

# 4. Compilar y empaquetar JAR
echo -e "\n${YELLOW}4. Compilando y empaquetando JAR...${NC}"
./mvnw clean package -DskipTests
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error en compilación${NC}"
    exit 1
fi

# Verificar que el JAR se creó
JAR_FILE=$(ls target/*.jar | head -1)
if [ -f "$JAR_FILE" ]; then
    JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
    echo -e "${GREEN}✅ JAR creado: $(basename $JAR_FILE) (${JAR_SIZE})${NC}"
else
    echo -e "${RED}❌ No se encontró el archivo JAR${NC}"
    exit 1
fi

# 5. Construir imagen Docker con tag de versión
echo -e "\n${YELLOW}5. Construyendo imagen Docker versionada...${NC}"
docker build -t proyecto-tienda:${VERSION} \
             -t proyecto-tienda:latest \
             -t proyecto-tienda:${RELEASE_DATE} \
             .

if [ $? -eq 0 ]; then
    IMAGE_SIZE=$(docker images proyecto-tienda:${VERSION} --format "{{.Size}}")
    echo -e "${GREEN}✅ Imagen Docker creada: proyecto-tienda:${VERSION} (${IMAGE_SIZE})${NC}"
else
    echo -e "${RED}❌ Error construyendo imagen Docker${NC}"
    exit 1
fi

# 6. Crear directorio de release
echo -e "\n${YELLOW}6. Creando estructura de release...${NC}"
mkdir -p ${RELEASE_DIR}
mkdir -p ${RELEASE_DIR}/scripts
mkdir -p ${RELEASE_DIR}/config
mkdir -p ${RELEASE_DIR}/docs

# 7. Copiar archivos necesarios
echo -e "\n${YELLOW}7. Copiando archivos para release...${NC}"

# JAR
cp target/*.jar ${RELEASE_DIR}/
echo "  ✅ JAR copiado"

# Scripts
cp scripts/deploy.sh ${RELEASE_DIR}/scripts/
cp scripts/deploy-quick.sh ${RELEASE_DIR}/scripts/
cp scripts/validate-system.sh ${RELEASE_DIR}/scripts/
cp scripts/health-check.sh ${RELEASE_DIR}/scripts/
cp scripts/status-report.sh ${RELEASE_DIR}/scripts/
cp scripts/validate-ports.sh ${RELEASE_DIR}/scripts/
cp scripts/test-connectivity.sh ${RELEASE_DIR}/scripts/
cp scripts/port-diagnostic.sh ${RELEASE_DIR}/scripts/
cp scripts/build-images.sh ${RELEASE_DIR}/scripts/
cp scripts/test-image.sh ${RELEASE_DIR}/scripts/
cp scripts/restart.sh ${RELEASE_DIR}/scripts/
chmod +x ${RELEASE_DIR}/scripts/*.sh
echo "  ✅ Scripts copiados (12 scripts)"

# Configuración
cp Dockerfile ${RELEASE_DIR}/
cp docker-compose.yml ${RELEASE_DIR}/
cp .env.example ${RELEASE_DIR}/config/
cp pom.xml ${RELEASE_DIR}/
cp mvnw ${RELEASE_DIR}/
cp mvnw.cmd ${RELEASE_DIR}/
cp -r .mvn ${RELEASE_DIR}/
echo "  ✅ Archivos de configuración copiados"

# Documentación
cp DEPLOYMENT.md ${RELEASE_DIR}/docs/
cp README.md ${RELEASE_DIR}/docs/
cp API.md ${RELEASE_DIR}/docs/
cp CHANGELOG.md ${RELEASE_DIR}/docs/
echo "  ✅ Documentación copiada"

# 8. Crear archivo VERSION.txt
echo -e "\n${YELLOW}8. Generando archivo de versión...${NC}"
cat > ${RELEASE_DIR}/VERSION.txt << EOF
=========================================
PROYECTO TIENDA PLAZA CHINA - VERSIÓN ${VERSION}
=========================================
Fecha de release: $(date)
Versión: ${VERSION}
Commit: $(git rev-parse --short HEAD)
Rama: ${CURRENT_BRANCH}

COMPONENTES:
- Spring Boot: $(grep -m1 "<version>" pom.xml | grep -o "[0-9][0-9.]*" | head -1)
- Java: 21
- MySQL: 8.0
- Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)

ARTEFACTOS:
- JAR: $(basename $JAR_FILE) (${JAR_SIZE})
- Imagen Docker: proyecto-tienda:${VERSION} (${IMAGE_SIZE})

SCRIPTS INCLUIDOS (12):
- deploy.sh: Despliegue completo
- deploy-quick.sh: Despliegue rápido
- validate-system.sh: Validación del sistema
- health-check.sh: Health check detallado
- status-report.sh: Reporte de estado
- validate-ports.sh: Validación de puertos
- test-connectivity.sh: Pruebas de conectividad
- port-diagnostic.sh: Diagnóstico de puertos
- build-images.sh: Construcción de imágenes
- test-image.sh: Prueba de imágenes
- restart.sh: Reinicio de servicios

PUERTOS CONFIGURADOS:
- App: 8081 → 8080
- MySQL: 3307 → 3306
- phpMyAdmin: 8082 → 80

BASE DE DATOS:
- Nombre: tiendaplazachina
- Usuario: root
- Password: (vacío)

DOCUMENTACIÓN:
- DEPLOYMENT.md: Guía de despliegue
- README.md: Información general
- API.md: Documentación de API
- CHANGELOG.md: Historial de cambios

=========================================
Para desplegar:
  cd release/proyecto-tienda-${VERSION}
  cp config/.env.example .env
  ./scripts/deploy.sh
=========================================
EOF
echo -e "${GREEN}✅ VERSION.txt creado${NC}"

# 9. Crear archivo tar.gz
echo -e "\n${YELLOW}9. Comprimiendo release...${NC}"
cd release
tar -czf ${RELEASE_FILE} proyecto-tienda-${VERSION}/
cd ..

if [ -f "release/${RELEASE_FILE}" ]; then
    RELEASE_SIZE=$(du -h "release/${RELEASE_FILE}" | cut -f1)
    echo -e "${GREEN}✅ Release comprimido: ${RELEASE_FILE} (${RELEASE_SIZE})${NC}"
else
    echo -e "${RED}❌ Error creando archivo comprimido${NC}"
    exit 1
fi

# 10. Generar checksums
echo -e "\n${YELLOW}10. Generando checksums...${NC}"
cd release
md5sum ${RELEASE_FILE} > ${RELEASE_FILE}.md5
sha256sum ${RELEASE_FILE} > ${RELEASE_FILE}.sha256
cd ..

echo "  ✅ MD5: $(cat release/${RELEASE_FILE}.md5 | cut -d' ' -f1)"
echo "  ✅ SHA256: $(cat release/${RELEASE_FILE}.sha256 | cut -d' ' -f1)"

# 11. Crear tag en git
echo -e "\n${YELLOW}11. Creando tag git v${VERSION}...${NC}"
git tag -a "v${VERSION}" -m "Release versión ${VERSION}"
git push origin "v${VERSION}"

echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}✅ VERSIÓN FINAL PREPARADA EXITOSAMENTE${NC}"
echo -e "${BLUE}=========================================${NC}"
echo "📦 Release: release/${RELEASE_FILE}"
echo "📏 Tamaño: ${RELEASE_SIZE}"
echo "📋 Checksums:"
echo "   MD5: release/${RELEASE_FILE}.md5"
echo "   SHA256: release/${RELEASE_FILE}.sha256"
echo -e "\n📂 Contenido del release:"
ls -la release/proyecto-tienda-${VERSION}/
echo -e "\n🚀 Para desplegar:"
echo "  cd release"
echo "  tar -xzf ${RELEASE_FILE}"
echo "  cd proyecto-tienda-${VERSION}"
echo "  cp config/.env.example .env"
echo "  ./scripts/deploy.sh"
echo -e "${BLUE}=========================================${NC}"