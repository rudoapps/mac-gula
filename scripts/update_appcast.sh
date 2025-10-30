#!/bin/bash

# Script para generar entradas de appcast.xml automáticamente
# Uso: ./scripts/update_appcast.sh VERSION BUILD_NUMBER [RELEASE_NOTES]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar argumentos
if [ $# -lt 2 ]; then
    log_error "Uso: $0 VERSION BUILD_NUMBER [RELEASE_NOTES]"
    echo "Ejemplo: $0 1.0.6 7 'Correcciones de bugs y mejoras'"
    exit 1
fi

VERSION=$1
BUILD_NUMBER=$2
RELEASE_NOTES=${3:-"Nueva versión con mejoras y correcciones"}

# Configuración
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Gula"
BUNDLE_ID="es.rudo.gula"
APPCAST_FILE="$PROJECT_DIR/appcast.xml"
ARCHIVE_PATH="$PROJECT_DIR/build/Gula.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build/export"
PRIVATE_KEY="$PROJECT_DIR/sparkle_private_key"
SPARKLE_BIN="$PROJECT_DIR/build/SourcePackages/artifacts/sparkle/Sparkle/bin"

log_info "Generando entrada de appcast para $APP_NAME $VERSION (build $BUILD_NUMBER)"

# Verificar que existe la clave privada
if [ ! -f "$PRIVATE_KEY" ]; then
    log_error "No se encuentra la clave privada de Sparkle: $PRIVATE_KEY"
    exit 1
fi

# Actualizar versiones en el proyecto
log_info "Actualizando versiones en el proyecto..."
cd "$PROJECT_DIR"
xcrun agvtool new-marketing-version "$VERSION" > /dev/null
xcrun agvtool new-version -all "$BUILD_NUMBER" > /dev/null

# Actualizar MARKETING_VERSION en project.pbxproj
sed -i '' "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $VERSION;/g" "$PROJECT_DIR/gula.xcodeproj/project.pbxproj"

log_info "Versiones actualizadas: $VERSION (build $BUILD_NUMBER)"

# Compilar la aplicación
log_info "Compilando la aplicación..."
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

xcodebuild -project "$PROJECT_DIR/gula.xcodeproj" \
    -scheme gula \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    archive \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM="" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    log_error "Error al compilar la aplicación"
    exit 1
fi

log_info "Aplicación compilada exitosamente"

# Exportar la aplicación
log_info "Exportando la aplicación..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$PROJECT_DIR/ExportOptions.plist" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    log_warning "Error al exportar con ExportOptions.plist, intentando exportación manual..."

    # Exportación manual
    mkdir -p "$EXPORT_PATH"
    cp -r "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$EXPORT_PATH/"
fi

# Verificar que existe la app exportada
if [ ! -d "$EXPORT_PATH/$APP_NAME.app" ]; then
    log_error "No se encontró la aplicación exportada"
    exit 1
fi

# Crear el archivo ZIP
log_info "Creando archivo ZIP..."
ZIP_FILE="$EXPORT_PATH/$APP_NAME-$VERSION.zip"
cd "$EXPORT_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_NAME.app" "$(basename "$ZIP_FILE")"

if [ ! -f "$ZIP_FILE" ]; then
    log_error "Error al crear el archivo ZIP"
    exit 1
fi

FILE_SIZE=$(stat -f%z "$ZIP_FILE")
log_info "Archivo ZIP creado: $(basename "$ZIP_FILE") ($FILE_SIZE bytes)"

# Firmar con Sparkle
log_info "Firmando con Sparkle..."
SIGNATURE_OUTPUT=$("$SPARKLE_BIN/sign_update" "$ZIP_FILE" --ed-key-file "$PRIVATE_KEY" 2>&1)

if [ $? -ne 0 ]; then
    log_error "Error al firmar con Sparkle: $SIGNATURE_OUTPUT"
    exit 1
fi

# Extraer solo la firma (última línea del output)
SIGNATURE=$(echo "$SIGNATURE_OUTPUT" | grep -o 'sparkle:edSignature="[^"]*"' | sed 's/sparkle:edSignature="\(.*\)"/\1/')

if [ -z "$SIGNATURE" ]; then
    log_error "No se pudo extraer la firma. Output: $SIGNATURE_OUTPUT"
    exit 1
fi

log_info "Firma generada exitosamente"

# Fecha actual en formato RFC 822
PUBDATE=$(date -u +"%a, %d %b %Y %H:%M:%S +0000")

# Generar entrada XML
log_info "Generando entrada XML..."

cat << EOF

<!-- Agregar esta entrada al archivo appcast.xml -->

        <item>
            <title>$APP_NAME $VERSION</title>
            <link>https://github.com/rudoapps/mac-gula/releases/tag/v$VERSION</link>
            <description><![CDATA[
                <h2>$APP_NAME $VERSION</h2>
                <p>$RELEASE_NOTES</p>

                <h3>Mejoras en esta versión:</h3>
                <ul>
                    <li>Actualización a versión $VERSION</li>
                </ul>
            ]]></description>
            <pubDate>$PUBDATE</pubDate>
            <guid isPermaLink="false">gula-$VERSION</guid>
            <sparkle:version>$BUILD_NUMBER</sparkle:version>
            <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>
            <enclosure
                url="https://github.com/rudoapps/mac-gula/releases/download/v$VERSION/$APP_NAME-$VERSION.zip"
                length="$FILE_SIZE"
                type="application/octet-stream"
                sparkle:edSignature="$SIGNATURE" />
        </item>

EOF

log_info "¡Listo!"
echo ""
log_info "Archivo ZIP: $ZIP_FILE"
log_info "Tamaño: $FILE_SIZE bytes"
log_info "Firma: $SIGNATURE"
echo ""
log_warning "Pasos siguientes:"
echo "  1. Copiar la entrada XML anterior al archivo appcast.xml"
echo "  2. Subir el archivo ZIP a GitHub Releases"
echo "  3. Commit y push de los cambios"
