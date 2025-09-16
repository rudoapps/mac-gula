#!/bin/bash

# Script para crear release en GitHub
# Uso: ./create_release.sh [version] [dmg_file]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_color() {
    echo -e "${2}${1}${NC}"
}

# Verificar que gh está instalado
if ! command -v gh &> /dev/null; then
    echo_color "❌ Error: GitHub CLI (gh) no está instalado" $RED
    echo_color "Instálalo con: brew install gh" $YELLOW
    exit 1
fi

# Verificar que estamos autenticados
if ! gh auth status &> /dev/null; then
    echo_color "❌ Error: No estás autenticado con GitHub" $RED
    echo_color "Ejecuta: gh auth login" $YELLOW
    exit 1
fi

# Cargar información del build anterior si existe
if [ -f "release_info.tmp" ]; then
    source release_info.tmp
    echo_color "📄 Cargando información del build anterior..." $BLUE
fi

# Obtener parámetros
if [ -z "$1" ]; then
    if [ -z "$VERSION" ]; then
        echo_color "📝 Introduce la versión (ej: 1.0.1):" $BLUE
        read -r VERSION
    else
        echo_color "📝 Versión detectada: $VERSION (Enter para confirmar, o introduce nueva):" $BLUE
        read -r NEW_VERSION
        if [ ! -z "$NEW_VERSION" ]; then
            VERSION="$NEW_VERSION"
        fi
    fi
else
    VERSION="$1"
fi

# Preguntar si es actualización crítica
echo_color "🔒 ¿Es una actualización crítica/forzosa? (y/N):" $YELLOW
read -r IS_CRITICAL
if [[ "$IS_CRITICAL" =~ ^[Yy]$ ]]; then
    CRITICAL_UPDATE="true"
    echo_color "⚠️  Marcada como actualización CRÍTICA - será forzosa" $RED
else
    CRITICAL_UPDATE="false"
fi

if [ -z "$2" ]; then
    if [ -z "$DMG_FILE" ]; then
        DMG_FILE="Gula-$VERSION.dmg"
    fi
else
    DMG_FILE="$2"
fi

# Verificar que el DMG existe
if [ ! -f "$DMG_FILE" ]; then
    echo_color "❌ Error: No se encontró $DMG_FILE" $RED
    echo_color "Ejecuta primero: ./build_release.sh $VERSION" $YELLOW
    exit 1
fi

echo_color "🚀 Creando release v$VERSION con $DMG_FILE..." $BLUE

# Crear el tag y release
TAG="v$VERSION"

echo_color "📝 Creando release notes..." $YELLOW

if [ "$CRITICAL_UPDATE" = "true" ]; then
    RELEASE_NOTES=$(cat << EOF
## 🔒 Gula $VERSION - Actualización Crítica

⚠️ **ACTUALIZACIÓN OBLIGATORIA** - Esta versión corrige problemas críticos de seguridad.

### 📥 Descarga
- [Descargar Gula-$VERSION.dmg](https://github.com/rudoapps/mac-gula/releases/download/v$VERSION/$DMG_FILE)

### 🔧 Instalación
1. Descarga el archivo DMG
2. Monta el DMG y arrastra Gula.app a la carpeta Aplicaciones
3. Ejecuta Gula desde el Launchpad o Aplicaciones

### 🛡️ Correcciones críticas
- Actualización de seguridad obligatoria
- Corrección de vulnerabilidades importantes
- Mejoras en la estabilidad del sistema

### 📋 Requisitos del sistema
- macOS 15.0 o superior
- Permisos de administrador para instalación

### ⚠️ Actualizaciones forzosas
Esta actualización se instalará automáticamente en todas las versiones anteriores por motivos de seguridad.

---
CRITICAL_UPDATE: true
🤖 Generado automáticamente
EOF
)
else
    RELEASE_NOTES=$(cat << EOF
## Gula $VERSION

### 📥 Descarga
- [Descargar Gula-$VERSION.dmg](https://github.com/rudoapps/mac-gula/releases/download/v$VERSION/$DMG_FILE)

### 🔧 Instalación
1. Descarga el archivo DMG
2. Monta el DMG y arrastra Gula.app a la carpeta Aplicaciones
3. Ejecuta Gula desde el Launchpad o Aplicaciones

### ✨ Características de esta versión
- Actualizaciones automáticas con Sparkle
- Gestión de proyectos mejorada
- Interfaz optimizada

### 📋 Requisitos del sistema
- macOS 15.0 o superior
- Permisos de administrador para instalación

### 🔄 Actualizaciones automáticas
Esta versión incluye actualizaciones automáticas. La app te notificará cuando haya nuevas versiones disponibles.

---
🤖 Generado automáticamente
EOF
)
fi

# Crear release en GitHub
echo_color "🏷️  Creando release en GitHub..." $BLUE
gh release create "$TAG" "$DMG_FILE" \
    --title "Gula $VERSION" \
    --notes "$RELEASE_NOTES" \
    --repo "rudoapps/mac-gula"

if [ $? -eq 0 ]; then
    echo_color "✅ Release creado exitosamente!" $GREEN
    echo_color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" $BLUE
    echo_color "🔗 URL: https://github.com/rudoapps/mac-gula/releases/tag/$TAG" $GREEN
    echo_color "📦 Archivo: $DMG_FILE subido correctamente" $GREEN
    
    if [ ! -z "$SIGNATURE" ]; then
        echo_color "🔐 Firma Sparkle: $SIGNATURE" $GREEN
        echo_color "📏 Tamaño: $FILESIZE bytes" $GREEN
        echo
        echo_color "⚠️  IMPORTANTE:" $YELLOW
        echo_color "El appcast.xml se actualizará automáticamente via GitHub Actions," $YELLOW
        echo_color "pero necesitas actualizar manualmente la firma Sparkle en el appcast." $YELLOW
        echo_color "Busca 'MANUAL_SIGNATURE_REQUIRED' en appcast.xml y reemplázalo con:" $YELLOW
        echo "$SIGNATURE"
    fi
    
    echo_color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" $BLUE
    echo_color "🎉 ¡Release publicado exitosamente!" $GREEN
    
    # Limpiar archivo temporal
    rm -f release_info.tmp
    
else
    echo_color "❌ Error al crear el release" $RED
    exit 1
fi