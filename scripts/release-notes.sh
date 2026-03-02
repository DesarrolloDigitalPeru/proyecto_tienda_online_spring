#!/bin/bash
# scripts/release-notes.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERSION="1.0.0"
RELEASE_DATE=$(date +%Y-%m-%d)

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}GENERANDO NOTAS DE RELEASE${NC}"
echo -e "${BLUE}=========================================${NC}"

cat > release/release-notes-v${VERSION}.md << EOF
# Release Notes - Proyecto Tienda Plaza China v${VERSION}

**Fecha:** ${RELEASE_DATE}  
**Versión:** ${VERSION}  
**Commit:** $(git rev-parse --short HEAD)

## 🚀 Nuevas Características

### Sprint 4 - Contenedores y Despliegue
- ✅ Containerización completa con Docker
- ✅ Orquestación con Docker Compose (MySQL, App, phpMyAdmin)
- ✅ Sistema de variables de entorno
- ✅ Scripts automatizados de despliegue
- ✅ Validación del sistema (40+ pruebas)
- ✅ Health checks detallados
- ✅ Documentación completa de despliegue

### Sprint 3 - Integración y Entrega Continua
- ✅ Pipeline CI/CD con GitHub Actions
- ✅ Análisis de calidad con SonarCloud
- ✅ Gestión de dependencias
- ✅ Maven Wrapper

### Sprint 2 - Desarrollo de Entidades
- ✅ Modelos de datos
- ✅ Repositorios JPA
- ✅ Servicios y controladores

### Sprint 1 - Configuración Inicial
- ✅ Estructura base del proyecto
- ✅ Dependencias de Spring Boot

## 📦 Artefactos

| Artefacto | Descripción | Ubicación |
|-----------|-------------|-----------|
| JAR | Aplicación ejecutable | \`target/*.jar\` |
| Imagen Docker | proyecto-tienda:${VERSION} | Docker Hub / Local |
| Release tar.gz | Paquete completo | \`release/proyecto-tienda-${VERSION}.tar.gz\` |

## 🔧 Configuración

### Base de Datos
- **Nombre:** tiendaplazachina
- **Usuario:** root
- **Password:** (vacío)
- **Puerto:** 3307

### Servicios
| Servicio | Puerto Host | Puerto Contenedor |
|----------|-------------|-------------------|
| App Spring Boot | 8081 | 8080 |
| MySQL | 3307 | 3306 |
| phpMyAdmin | 8082 | 80 |

## 📊 Scripts Incluidos (12)

\`\`\`bash
scripts/
├── deploy.sh          # Despliegue completo
├── deploy-quick.sh    # Despliegue rápido
├── validate-system.sh # Validación del sistema
├── health-check.sh    # Health check detallado
├── status-report.sh   # Reporte de estado
├── validate-ports.sh  # Validación de puertos
├── test-connectivity.sh # Pruebas de conectividad
├── port-diagnostic.sh # Diagnóstico de puertos
├── build-images.sh    # Construcción de imágenes
├── test-image.sh      # Prueba de imágenes
├── restart.sh         # Reinicio de servicios
└── release-version.sh # Preparar versión final
\`\`\`

## 📚 Documentación

- \`DEPLOYMENT.md\` - Guía completa de despliegue
- \`README.md\` - Información general
- \`API.md\` - Documentación de endpoints
- \`CHANGELOG.md\` - Historial de cambios
- \`VERSION.txt\` - Información de versión

## ✅ Validaciones

El release ha sido validado con:
- ✅ 40+ pruebas automáticas
- ✅ Health checks de todos los servicios
- ✅ Verificación de puertos y conectividad
- ✅ Integridad de archivos (MD5, SHA256)
- ✅ Compilación exitosa con Maven
- ✅ Construcción de imagen Docker

## 🚀 Cómo Usar

\`\`\`bash
# Descargar release
tar -xzf proyecto-tienda-${VERSION}.tar.gz
cd proyecto-tienda-${VERSION}

# Configurar
cp config/.env.example .env

# Desplegar
./scripts/deploy.sh

# Acceder
http://localhost:8081
\`\`\`

## 🐛 Issues Conocidos

- Ninguno reportado para esta versión

## 📈 Próximos Pasos (Sprint 5)

- Orquestación con Kubernetes
- Escalado horizontal
- Balanceo de carga
- Monitoreo avanzado con Prometheus/Grafana

## 👥 Equipo

- Desarrollo: Equipo de Desarrollo
- QA: Equipo de Calidad
- DevOps: Equipo de Infraestructura

## 📞 Soporte

Para issues: [Crear issue en GitHub](link)  
Email: desarrollo@ejemplo.com

---

**¡Gracias por usar Proyecto Tienda Plaza China!** 🎉
EOF

echo -e "${GREEN}✅ Notas de release generadas: release/release-notes-v${VERSION}.md${NC}"
cat release/release-notes-v${VERSION}.md