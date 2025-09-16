#!/bin/bash

# Script para compilar y crear release de Gula
# Uso: ./build_release.sh [version]

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

# Verificar que estamos en el directorio correcto
if [ ! -f "gula.xcodeproj/project.pbxproj" ]; then
    echo_color "❌ Error: No se encontró gula.xcodeproj" $RED
    echo_color "Ejecuta este script desde el directorio raíz del proyecto" $YELLOW
    exit 1
fi

# Obtener versión
if [ -z "$1" ]; then
    echo_color "📝 Introduce la versión (ej: 1.0.1):" $BLUE
    read -r VERSION
else
    VERSION="$1"
fi

if [ -z "$VERSION" ]; then
    echo_color "❌ Error: Versión requerida" $RED
    exit 1
fi

echo_color "🚀 Iniciando build para versión $VERSION..." $BLUE

# Limpiar build anterior
echo_color "🧹 Limpiando builds anteriores..." $YELLOW
rm -rf build/
rm -f *.dmg

# Crear directorio de build
mkdir -p build

# Compilar app
echo_color "⚙️  Compilando aplicación..." $BLUE
xcodebuild -project gula.xcodeproj \
    -scheme gula \
    -configuration Release \
    -derivedDataPath build/ \
    -archivePath build/gula.xcarchive \
    archive

# Crear ExportOptions.plist si no existe
if [ ! -f "ExportOptions.plist" ]; then
    echo_color "📄 Creando ExportOptions.plist..." $YELLOW
    cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF
fi

# Exportar app
echo_color "📦 Exportando aplicación..." $BLUE
xcodebuild -exportArchive \
    -archivePath build/gula.xcarchive \
    -exportPath build/export \
    -exportOptionsPlist ExportOptions.plist

# Verificar que create-dmg está instalado
if ! command -v create-dmg &> /dev/null; then
    echo_color "⚠️  create-dmg no está instalado. Instalando..." $YELLOW
    brew install create-dmg
fi

# Crear DMG
echo_color "💿 Creando DMG..." $BLUE
DMG_NAME="Gula-$VERSION.dmg"

create-dmg \
    --volname "Gula $VERSION" \
    --window-pos 200 120 \
    --window-size 600 300 \
    --icon-size 100 \
    --icon "gula.app" 175 120 \
    --hide-extension "gula.app" \
    --app-drop-link 425 120 \
    "$DMG_NAME" \
    "build/export/"

# Firmar DMG con Sparkle
echo_color "🔐 Firmando DMG con Sparkle..." $BLUE
if [ -f "sparkle_private_key.pem" ]; then
    SIGNATURE=$(openssl dgst -sha256 -sign sparkle_private_key.pem "$DMG_NAME" | base64 | tr -d '\n')
    FILESIZE=$(stat -f%z "$DMG_NAME")
    
    echo_color "✅ Build completado exitosamente!" $GREEN
    echo_color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" $BLUE
    echo_color "📁 Archivo: $DMG_NAME" $GREEN
    echo_color "📏 Tamaño: $FILESIZE bytes" $GREEN
    echo_color "🔐 Firma Sparkle:" $GREEN
    echo "$SIGNATURE"
    echo_color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" $BLUE
    echo
    echo_color "🚀 Siguiente paso:" $YELLOW
    echo_color "./create_release.sh $VERSION $DMG_NAME" $BLUE
    
    # Guardar información para el siguiente script
    cat > release_info.tmp << EOF
VERSION=$VERSION
DMG_FILE=$DMG_NAME
SIGNATURE=$SIGNATURE
FILESIZE=$FILESIZE
EOF
    
else
    echo_color "⚠️  No se encontró sparkle_private_key.pem" $YELLOW
    echo_color "El DMG se creó pero no se pudo firmar automáticamente" $YELLOW
    echo_color "Puedes firmarlo manualmente con: ./sign_update.sh $DMG_NAME" $BLUE
fi

echo_color "🎉 ¡Listo!" $GREEN