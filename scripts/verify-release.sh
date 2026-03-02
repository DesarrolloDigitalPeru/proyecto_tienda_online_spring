#!/bin/bash
# scripts/verify-release.sh

echo "========================================="
echo "VERIFICANDO RELEASE"
echo "========================================="

# Buscar archivo tar.gz (versión más flexible)
TAR_FILE=$(ls *.tar.gz 2>/dev/null | head -1)

if [ -z "$TAR_FILE" ]; then
    echo "❌ No se encontró archivo .tar.gz"
    echo "   Archivos disponibles:"
    ls -la | grep "\.tar\.gz" || echo "   Ninguno"
    exit 1
fi

echo "1. Verificando integridad del archivo: $TAR_FILE"
echo "   Tamaño: $(du -h "$TAR_FILE" | cut -f1)"
echo "   Fecha: $(stat -c %y "$TAR_FILE" 2>/dev/null || date -r "$TAR_FILE")"

# Verificar que es un gzip válido
if tar tzf "$TAR_FILE" &>/dev/null; then
    echo "   ✅ Archivo válido"
else
    echo "   ❌ Archivo corrupto o no es un tar.gz válido"
    exit 1
fi

echo -e "\n2. Contenido del archivo:"
tar tzf "$TAR_FILE" | head -10 | sed 's/^/   - /'

echo -e "\n3. Verificación completada:"
echo "   ✅ Release válido: $TAR_FILE"
echo "========================================="
