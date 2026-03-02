#!/bin/bash
# scripts/final-verification.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}VERIFICACIÓN FINAL DEL SPRINT 4${NC}"
echo -e "${BLUE}=========================================${NC}"

TOTAL_CHECKS=0
PASSED_CHECKS=0

# Función para verificar
check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if eval $2; then
        echo -e "  ${GREEN}✅ $1${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "  ${RED}❌ $1${NC}"
    fi
}

# Verificar archivos de código
echo -e "\n${YELLOW}📁 Verificando archivos de código:${NC}"
check "Dockerfile existe" "[ -f 'Dockerfile' ]"
check "docker-compose.yml existe" "[ -f 'docker-compose.yml' ]"
check ".env.example existe" "[ -f '.env.example' ]"
check "pom.xml existe" "[ -f 'pom.xml' ]"

# Verificar scripts
echo -e "\n${YELLOW}📜 Verificando scripts:${NC}"
check "scripts/deploy.sh existe" "[ -f 'scripts/deploy.sh' ]"
check "scripts/validate-system.sh existe" "[ -f 'scripts/validate-system.sh' ]"
check "scripts/health-check.sh existe" "[ -f 'scripts/health-check.sh' ]"
check "scripts/release-version.sh existe" "[ -f 'scripts/release-version.sh' ]"
check "scripts/close-sprint.sh existe" "[ -f 'scripts/close-sprint.sh' ]"

# Verificar documentación
echo -e "\n${YELLOW}📚 Verificando documentación:${NC}"
check "DEPLOYMENT.md existe" "[ -f 'DEPLOYMENT.md' ]"
check "README.md existe" "[ -f 'README.md' ]"
check "API.md existe" "[ -f 'API.md' ]"
check "CHANGELOG.md existe" "[ -f 'CHANGELOG.md' ]"

# Verificar release
echo -e "\n${YELLOW}📦 Verificando release:${NC}"
check "Release tar.gz existe" "[ -f 'release/proyecto-tienda-1.0.0.tar.gz' ]"
check "Checksum MD5 existe" "[ -f 'release/proyecto-tienda-1.0.0.tar.gz.md5' ]"
check "Checksum SHA256 existe" "[ -f 'release/proyecto-tienda-1.0.0.tar.gz.sha256' ]"
check "Release notes existen" "[ -f 'release/release-notes-v1.0.0.md' ]"

# Verificar reportes de sprint
echo -e "\n${YELLOW}📊 Verificando reportes:${NC}"
check "SPRINT4-COMPLETED.md existe" "[ -f 'SPRINT4-COMPLETED.md' ]"
check "SPRINT4-SUMMARY.md existe" "[ -f 'SPRINT4-SUMMARY.md' ]"

# Verificar tags git
echo -e "\n${YELLOW}🏷️  Verificando tags:${NC}"
check "Tag v1.0.0 existe" "git tag | grep -q 'v1.0.0'"
check "Tag sprint4 existe" "git tag | grep -q 'sprint4-'"

# Mostrar resumen
echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}RESUMEN DE VERIFICACIÓN${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Total verificaciones: ${YELLOW}${TOTAL_CHECKS}${NC}"
echo -e "${GREEN}✅ Pasadas: ${PASSED_CHECKS}${NC}"
echo -e "${RED}❌ Falladas: $((TOTAL_CHECKS - PASSED_CHECKS))${NC}"

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    echo -e "\n${GREEN}✅ TODO CORRECTO - SPRINT 4 COMPLETADO${NC}"
else
    echo -e "\n${RED}❌ FALTAN $((TOTAL_CHECKS - PASSED_CHECKS)) VERIFICACIONES${NC}"
fi
echo -e "${BLUE}=========================================${NC}"