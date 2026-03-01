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