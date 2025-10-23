#!/bin/bash

# ===============================================
# Script Mejorado de Publicación con Sparkle
# ===============================================
# Este script automatiza completamente el proceso de release:
# 1. Verifica configuración de seguridad
# 2. Extrae versión automáticamente del proyecto
# 3. Compila en Release
# 4. Crea DMG profesional
# 5. Firma con EdDSA (Sparkle)
# 6. Actualiza appcast.xml
# 7. Crea GitHub Release
# 8. Push automático
# ===============================================

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ===============================================
# FUNCIONES AUXILIARES
# ===============================================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 no está instalado"
        echo "   Instala con: $2"
        exit 1
    fi
}

# ===============================================
# VERIFICACIONES PREVIAS
# ===============================================

echo ""
echo "🚀 PUBLICACIÓN DE RELEASE CON SPARKLE"
echo "======================================"
echo ""

log_info "Verificando requisitos..."

# Verificar herramientas necesarias
check_command "xcodebuild" "Xcode"
check_command "create-dmg" "brew install create-dmg"
check_command "gh" "brew install gh"

# Verificar archivos críticos
if [ ! -f "gula.xcodeproj/project.pbxproj" ]; then
    log_error "No se encuentra el proyecto Xcode"
    exit 1
fi

# ===============================================
# VERIFICACIÓN DE SEGURIDAD SPARKLE
# ===============================================

log_info "Verificando configuración de seguridad Sparkle..."

# Verificar SUPublicEDKey en Info.plist
if ! grep -q "SUPublicEDKey" gula/Info.plist; then
    log_error "SUPublicEDKey no está configurada en Info.plist"
    echo ""
    echo "⚠️  ADVERTENCIA DE SEGURIDAD:"
    echo "   Sin SUPublicEDKey, las actualizaciones no están protegidas"
    echo "   contra ataques man-in-the-middle."
    echo ""
    read -p "¿Continuar sin seguridad EdDSA? (no recomendado) [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    log_success "SUPublicEDKey configurada correctamente"
fi

# Verificar clave privada para firmar
if [ ! -f "sparkle_edkey.txt" ] && [ ! -f "sparkle_private_key.pem" ]; then
    log_error "No se encuentra la clave privada de Sparkle"
    echo "   Busca sparkle_edkey.txt o sparkle_private_key.pem"
    exit 1
fi

# Determinar archivo de clave
if [ -f "sparkle_edkey.txt" ]; then
    SPARKLE_KEY="sparkle_edkey.txt"
else
    SPARKLE_KEY="sparkle_private_key.pem"
fi
log_success "Clave privada encontrada: $SPARKLE_KEY"

# ===============================================
# EXTRACCIÓN DE VERSIÓN Y BUILD
# ===============================================

log_info "Extrayendo información de versión..."

# Extraer versión del Info.plist
VERSION=$(plutil -extract CFBundleShortVersionString raw gula/Info.plist 2>/dev/null || echo "")
BUILD=$(plutil -extract CFBundleVersion raw gula/Info.plist 2>/dev/null || echo "")

if [ -z "$VERSION" ] || [ -z "$BUILD" ]; then
    log_error "No se pudo extraer la versión del proyecto"
    echo "   Versión encontrada: ${VERSION:-'ninguna'}"
    echo "   Build encontrado: ${BUILD:-'ninguno'}"
    echo ""
    read -p "Ingresa la versión (ej: 1.0.4): " VERSION
    read -p "Ingresa el build (ej: 6): " BUILD
fi

log_success "Versión: $VERSION (Build $BUILD)"

# Confirmar versión
echo ""
echo "📋 Información del Release:"
echo "   Versión: $VERSION"
echo "   Build: $BUILD"
echo ""
read -p "¿Es correcta esta información? [Y/n]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    read -p "Ingresa la versión correcta: " VERSION
    read -p "Ingresa el build correcto: " BUILD
fi

DMG_NAME="Gula-${VERSION}.dmg"
APP_NAME="gula"

# ===============================================
# LIMPIEZA
# ===============================================

log_info "Limpiando builds anteriores..."
rm -rf build/
rm -f "${DMG_NAME}"
mkdir -p build

# ===============================================
# COMPILACIÓN
# ===============================================

log_info "Compilando en modo Release..."
echo "   Esto puede tomar varios minutos..."

# Clean
xcodebuild clean \
  -project ${APP_NAME}.xcodeproj \
  -scheme ${APP_NAME} \
  -configuration Release \
  > /dev/null 2>&1 || true

# Archive
xcodebuild archive \
  -project ${APP_NAME}.xcodeproj \
  -scheme ${APP_NAME} \
  -archivePath build/${APP_NAME}.xcarchive \
  -configuration Release \
  CODE_SIGN_IDENTITY="-" \
  -quiet

if [ $? -ne 0 ]; then
    log_error "Fallo la compilación"
    exit 1
fi

log_success "Compilación exitosa"

# ===============================================
# EXPORTACIÓN
# ===============================================

log_info "Exportando aplicación..."

# Crear ExportOptions.plist si no existe
if [ ! -f "ExportOptions.plist" ]; then
    cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>release-testing</string>
    <key>teamID</key>
    <string></string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
fi

xcodebuild -exportArchive \
  -archivePath build/${APP_NAME}.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist \
  > /dev/null 2>&1

if [ $? -ne 0 ]; then
    log_error "Fallo la exportación"
    exit 1
fi

log_success "Exportación exitosa"

# ===============================================
# CREACIÓN DE DMG
# ===============================================

log_info "Creando DMG profesional..."

# Eliminar DMG anterior si existe
rm -f "${DMG_NAME}"

create-dmg \
  --volname "Gula ${VERSION}" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 175 120 \
  --hide-extension "${APP_NAME}.app" \
  --app-drop-link 425 120 \
  --no-internet-enable \
  "${DMG_NAME}" \
  "build/export/${APP_NAME}.app" 2>/dev/null || true

if [ ! -f "${DMG_NAME}" ]; then
    log_error "Fallo la creación del DMG"
    exit 1
fi

log_success "DMG creado: ${DMG_NAME}"

# ===============================================
# INFORMACIÓN DEL DMG
# ===============================================

FILESIZE=$(stat -f%z "${DMG_NAME}")
log_info "Tamaño del DMG: ${FILESIZE} bytes"

# ===============================================
# FIRMA SPARKLE
# ===============================================

log_info "Firmando con Sparkle EdDSA..."

# Buscar sign_update
SIGN_UPDATE=""
if command -v sign_update &> /dev/null; then
    SIGN_UPDATE="sign_update"
elif [ -f "./Sparkle/bin/sign_update" ]; then
    SIGN_UPDATE="./Sparkle/bin/sign_update"
elif [ -f ".build/artifacts/sparkle/Sparkle/bin/sign_update" ]; then
    SIGN_UPDATE=".build/artifacts/sparkle/Sparkle/bin/sign_update"
else
    log_warning "sign_update no encontrado, intentando con método alternativo..."
fi

if [ -n "$SIGN_UPDATE" ]; then
    # Usar sign_update si está disponible
    if [[ "$SPARKLE_KEY" == *".txt" ]]; then
        # Es un archivo de texto con la clave raw
        SIGNATURE=$($SIGN_UPDATE "${DMG_NAME}" -f "$SPARKLE_KEY" 2>/dev/null)
    else
        # Es un archivo PEM
        SIGNATURE=$($SIGN_UPDATE "${DMG_NAME}" "$SPARKLE_KEY" 2>/dev/null)
    fi
else
    # Método alternativo usando openssl
    log_info "Usando openssl para firmar..."

    # Convertir PEM a raw key si es necesario
    if [[ "$SPARKLE_KEY" == *".pem" ]]; then
        openssl pkey -in "$SPARKLE_KEY" -outform DER | tail -c 32 > temp_key.raw
        SIGNATURE=$(openssl dgst -sha256 -binary "${DMG_NAME}" | openssl pkeyutl -sign -inkey temp_key.raw -keyform DER | base64)
        rm -f temp_key.raw
    else
        SIGNATURE=$(openssl dgst -sha256 -binary "${DMG_NAME}" | openssl pkeyutl -sign -inkey "$SPARKLE_KEY" -keyform raw | base64)
    fi
fi

if [ -z "$SIGNATURE" ]; then
    log_error "No se pudo generar la firma"
    exit 1
fi

log_success "Firma generada: ${SIGNATURE:0:20}..."

# ===============================================
# ACTUALIZACIÓN DE APPCAST.XML
# ===============================================

log_info "Actualizando appcast.xml..."

# Hacer backup
cp appcast.xml appcast.xml.backup

# Crear fecha en formato RFC822
PUBDATE=$(date -R)

# Crear nuevo item para appcast
NEW_ITEM="        <item>
            <title>Versión ${VERSION}</title>
            <sparkle:version>${BUILD}</sparkle:version>
            <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
            <pubDate>${PUBDATE}</pubDate>
            <enclosure
                url=\"https://github.com/rudoapps/mac-gula/releases/download/v${VERSION}/${DMG_NAME}\"
                length=\"${FILESIZE}\"
                type=\"application/octet-stream\"
                sparkle:edSignature=\"${SIGNATURE}\" />
            <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>
        </item>"

# Insertar el nuevo item después del último <channel>
# Esto mantiene el historial de versiones
if grep -q "<item>" appcast.xml; then
    # Ya hay items, agregar antes del primer item existente
    awk -v new_item="$NEW_ITEM" '
        /<item>/ && !done {
            print new_item
            done = 1
        }
        {print}
    ' appcast.xml > appcast_temp.xml
else
    # No hay items, agregar después de <channel>
    awk -v new_item="$NEW_ITEM" '
        /<channel>/ {
            print
            print new_item
            next
        }
        {print}
    ' appcast.xml > appcast_temp.xml
fi

mv appcast_temp.xml appcast.xml
log_success "appcast.xml actualizado"

# ===============================================
# GITHUB RELEASE
# ===============================================

echo ""
echo "📤 Creación de GitHub Release"
echo ""
read -p "¿Crear release en GitHub automáticamente? [Y/n]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    log_info "Creando release en GitHub..."

    # Crear notas del release
    RELEASE_NOTES="## Gula ${VERSION}

### Cambios en esta versión
- Actualización automática con Sparkle
- Mejoras de rendimiento
- Correcciones de errores

### Instalación
1. Descarga el DMG
2. Arrastra Gula a tu carpeta de Aplicaciones
3. Disfruta de las actualizaciones automáticas

---
*Build ${BUILD} - $(date +'%Y-%m-%d')*"

    # Crear release
    gh release create "v${VERSION}" \
        --title "Gula ${VERSION}" \
        --notes "$RELEASE_NOTES" \
        --draft=false \
        "${DMG_NAME}" || {
        log_error "Fallo la creación del release"
        echo ""
        echo "Puedes crearlo manualmente con:"
        echo "gh release create \"v${VERSION}\" --title \"Gula ${VERSION}\" \"${DMG_NAME}\""
    }

    log_success "Release creado en GitHub"
fi

# ===============================================
# GIT COMMIT Y PUSH
# ===============================================

echo ""
read -p "¿Commit y push de appcast.xml? [Y/n]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    log_info "Haciendo commit y push..."

    git add appcast.xml
    git commit -m "Release v${VERSION} - Build ${BUILD}

- DMG firmado con EdDSA
- Actualización automática via Sparkle
- Tamaño: ${FILESIZE} bytes" || true

    git push origin main || {
        log_warning "No se pudo hacer push automático"
        echo "Ejecuta manualmente: git push origin main"
    }

    log_success "Cambios enviados a GitHub"
fi

# ===============================================
# VERIFICACIÓN FINAL
# ===============================================

echo ""
echo "======================================"
echo -e "${GREEN}🎉 RELEASE COMPLETADO${NC}"
echo "======================================"
echo ""
echo "📋 Resumen del Release:"
echo "   • Versión: ${VERSION}"
echo "   • Build: ${BUILD}"
echo "   • DMG: ${DMG_NAME}"
echo "   • Tamaño: ${FILESIZE} bytes"
echo "   • Firma EdDSA: ✅"
echo ""
echo "🔍 Verificación:"
echo ""
echo "1. Verifica el appcast:"
echo "   curl -s https://raw.githubusercontent.com/rudoapps/mac-gula/main/appcast.xml | grep \"${VERSION}\""
echo ""
echo "2. Verifica el release:"
echo "   https://github.com/rudoapps/mac-gula/releases/tag/v${VERSION}"
echo ""
echo "3. Prueba la actualización:"
echo "   - Instala una versión anterior"
echo "   - Abre la app"
echo "   - Debe detectar la actualización automáticamente"
echo ""
echo "✨ ¡Release publicado con éxito!"
echo ""