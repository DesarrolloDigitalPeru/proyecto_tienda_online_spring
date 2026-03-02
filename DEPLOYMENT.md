# Guía de Despliegue - Proyecto Tienda Plaza China

## 📋 Tabla de Contenidos
1. [Descripción General](#descripción-general)
2. [Requisitos del Sistema](#requisitos-del-sistema)
3. [Arquitectura de la Aplicación](#arquitectura-de-la-aplicación)
4. [Configuración del Entorno](#configuración-del-entorno)
5. [Despliegue con Docker](#despliegue-con-docker)
6. [Verificación del Despliegue](#verificación-del-despliegue)
7. [Operaciones Comunes](#operaciones-comunes)
8. [Solución de Problemas](#solución-de-problemas)
9. [Respaldo y Restauración](#respaldo-y-restauración)
10. [Referencias](#referencias)

---

## 1. Descripción General

**Proyecto:** Tienda Plaza China  
**Versión:** 1.0.0  
**Tecnologías:** Spring Boot, MySQL, Docker  
**Puertos:** 8081 (App), 3307 (MySQL), 8082 (phpMyAdmin)

Este documento proporciona instrucciones detalladas para desplegar la aplicación Tienda Plaza China en entornos de desarrollo, pruebas y producción utilizando contenedores Docker.

---

## 2. Requisitos del Sistema

### 2.1 Requisitos Mínimos
| Recurso | Requerimiento |
|---------|---------------|
| RAM | 2 GB |
| Disco | 5 GB libres |
| CPU | 1 núcleo |

### 2.2 Software Requerido
| Software | Versión Mínima | Comando Verificación |
|----------|----------------|---------------------|
| Docker | 20.10.x | `docker --version` |
| Docker Compose | 2.0.x | `docker-compose --version` |
| Git | 2.30.x | `git --version` |
| Java (opcional) | 21 | `java -version` |

---

## 3. Arquitectura de la Aplicación

### 3.1 Diagrama de Componentes

┌─────────────────────────────────────────────┐
│ Host (Ubuntu/Windows/Mac) │
│ ┌──────────┐ ┌──────────┐ │
│ │ MySQL │◄────►│ App │ │
│ │ Puerto │ │ Puerto │ │
│ │ 3307:3306│ │ 8081:8080│ │
│ └────┬─────┘ └────┬─────┘ │
│ │ │ │
│ ▼ │ │
│ ┌──────────┐ │ │
│ │phpMyAdmin│◄──────────┘ │
│ │ Puerto │ │
│ │ 8082:80 │ │
│ └──────────┘ │
└─────────────────────────────────────────────┘
### 3.2 Servicios y Puertos
| Servicio | Puerto Host | Puerto Contenedor | Propósito |
|----------|-------------|-------------------|-----------|
| App Spring Boot | 8081 | 8080 | Aplicación principal |
| MySQL | 3307 | 3306 | Base de datos |
| phpMyAdmin | 8082 | 80 | Administración BD |

### 3.3 Redes y Volúmenes
| Recurso | Nombre | Propósito |
|---------|--------|-----------|
| Red | proyecto_network | Comunicación entre contenedores |
| Volumen | mysql_data | Persistencia de datos MySQL |

---

## 4. Configuración del Entorno

### 4.1 Variables de Entorno

#### Archivo `.env.example`
```env
# MySQL Configuration
MYSQL_ROOT_PASSWORD=      # Vacío para root sin contraseña
MYSQL_DATABASE=tiendaplazachina
MYSQL_USER=root
MYSQL_PASSWORD=           # Vacío para root sin contraseña

# Spring Boot Configuration
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/tiendaplazachina?useSSL=false&serverTimezone=America/Lima&allowPublicKeyRetrieval=true
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SPRING_PROFILES_ACTIVE=docker

# Application Configuration
SERVER_PORT=8080