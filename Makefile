# Makefile para comandos Docker
.PHONY: help build test analyze

# Colores
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help: ## Muestra esta ayuda
	@echo "${GREEN}Comandos disponibles para Punto 4:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-15s${NC} %s\n", $$1, $$2}'

build: ## Construye la imagen Docker con múltiples tags
	@echo "${YELLOW}Ejecutando build-images.sh...${NC}"
	@./scripts/build-images.sh

test: ## Prueba la imagen localmente
	@echo "${YELLOW}Ejecutando test-image.sh...${NC}"
	@./scripts/test-image.sh

analyze: ## Analiza tamaño y capas de la imagen
	@echo "${YELLOW}Ejecutando analyze-image.sh...${NC}"
	@./scripts/analyze-image.sh

all: build test analyze ## Ejecuta build, test y analyze
	@echo "${GREEN}✅ Proceso completo finalizado${NC}"

deploy: ## Despliega la aplicación con validaciones
	@echo "${YELLOW}Ejecutando deploy.sh...${NC}"
	@./scripts/deploy.sh

deploy-quick: ## Despliegue rápido sin validaciones
	@echo "${YELLOW}Ejecutando deploy-quick.sh...${NC}"
	@./scripts/deploy-quick.sh

verify: ## Verifica el estado del despliegue
	@echo "${YELLOW}Ejecutando verify-deploy.sh...${NC}"
	@./scripts/verify-deploy.sh

restart: ## Reinicia los servicios
	@echo "${YELLOW}Ejecutando restart.sh...${NC}"
	@./scripts/restart.sh

logs: ## Muestra logs en tiempo real
	@docker-compose logs -f

status: ## Muestra estado de los servicios
	@docker-compose ps

down: ## Detiene todos los servicios
	@echo "${YELLOW}Deteniendo servicios...${NC}"
	@docker-compose down

validate-ports: ## Valida configuración de puertos
	@echo "${YELLOW}Ejecutando validate-ports.sh...${NC}"
	@./scripts/validate-ports.sh

test-connectivity: ## Prueba conectividad entre servicios
	@echo "${YELLOW}Ejecutando test-connectivity.sh...${NC}"
	@./scripts/test-connectivity.sh

port-diagnostic: ## Diagnóstico completo de puertos
	@echo "${YELLOW}Ejecutando port-diagnostic.sh...${NC}"
	@./scripts/port-diagnostic.sh

# Comando combinado para punto 6
punto6: validate-ports test-connectivity port-diagnostic ## Ejecuta todas las validaciones del punto 6
	@echo "${GREEN}✅ Punto 6 completado${NC}"

validate-system: ## Valida ejecución completa del sistema
	@echo "${YELLOW}Ejecutando validate-system.sh...${NC}"
	@./scripts/validate-system.sh

health-check: ## Health check detallado de servicios
	@echo "${YELLOW}Ejecutando health-check.sh...${NC}"
	@./scripts/health-check.sh

status-report: ## Genera reporte de estado del sistema
	@echo "${YELLOW}Ejecutando status-report.sh...${NC}"
	@./scripts/status-report.sh

# Comando combinado para punto 7
punto7: validate-system health-check status-report ## Ejecuta todas las validaciones del punto 7
	@echo "${GREEN}✅ Punto 7 completado${NC}"

# Documentación
docs: ## Abre la documentación en el navegador
	@echo "${YELLOW}Documentación disponible:${NC}"
	@echo "  📄 DEPLOYMENT.md - Guía de despliegue"
	@echo "  📄 API.md - Documentación de API"
	@echo "  📄 README.md - Información general"
	@echo "  📄 CHANGELOG.md - Historial de cambios"
	@if command -v open >/dev/null 2>&1; then \
		open DEPLOYMENT.md; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open DEPLOYMENT.md; \
	else \
		echo "Abre manualmente los archivos MD"; \
	fi

# Comando combinado para punto 8
punto8: ## Genera y verifica toda la documentación
	@echo "${YELLOW}Verificando documentación...${NC}"
	@if [ -f "DEPLOYMENT.md" ] && [ -f "API.md" ] && [ -f "README.md" ] && [ -f "CHANGELOG.md" ]; then \
		echo "${GREEN}✅ Toda la documentación existe${NC}"; \
		wc -l DEPLOYMENT.md API.md README.md CHANGELOG.md | grep -v total; \
		echo "${GREEN}✅ Punto 8 completado${NC}"; \
	else \
		echo "${RED}❌ Falta documentación${NC}"; \
		exit 1; \
	fi

	# Release commands
release: ## Prepara versión final (Punto 9)
	@echo "${YELLOW}Ejecutando release-version.sh...${NC}"
	@./scripts/release-version.sh

verify-release: ## Verifica el release generado
	@echo "${YELLOW}Ejecutando verify-release.sh...${NC}"
	@./scripts/verify-release.sh

release-notes: ## Genera notas de release
	@echo "${YELLOW}Ejecutando release-notes.sh...${NC}"
	@./scripts/release-notes.sh

# Comando combinado para punto 9
punto9: release verify-release release-notes ## Ejecuta todo el proceso de release
	@echo "${GREEN}✅ Punto 9 completado${NC}"
	@echo "Release disponible en: release/"
	@ls -la release/