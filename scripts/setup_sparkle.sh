#!/bin/bash

# Script de configuración para Sparkle con repositorio separado
# Este script te ayuda a configurar Sparkle paso a paso

set -e

echo "🔧 Configuración de Sparkle para Gula"
echo "======================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Paso 1: Verificar si Sparkle tools están descargados
echo "Paso 1: Verificar Sparkle tools"
echo "--------------------------------"

if [ ! -f "./bin/generate_keys" ]; then
    print_info "Descargando Sparkle tools..."
    curl -L -o sparkle.zip https://github.com/sparkle-project/Sparkle/releases/download/2.7.3/Sparkle-for-Swift-Package-Manager.zip
    unzip -q sparkle.zip
    rm sparkle.zip
    print_success "Sparkle tools descargados"
else
    print_success "Sparkle tools ya están disponibles"
fi

echo ""

# Paso 2: Generar o verificar claves
echo "Paso 2: Claves de firma"
echo "------------------------"

if [ -f "sparkle_private_key.pem" ] && [ -f "sparkle_public_key.pem" ]; then
    print_success "Claves existentes encontradas"
    echo ""
    read -p "¿Quieres generar nuevas claves? (esto invalidará las actualizaciones antiguas) [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        GENERATE_KEYS=true
    else
        GENERATE_KEYS=false
    fi
else
    print_warning "No se encontraron claves existentes"
    GENERATE_KEYS=true
fi

if [ "$GENERATE_KEYS" = true ]; then
    print_info "Generando nuevas claves..."
    ./bin/generate_keys > keys_output.txt

    # Extraer claves
    PRIVATE_KEY=$(grep "Private key:" keys_output.txt | cut -d' ' -f3-)
    PUBLIC_KEY=$(grep "Public key:" keys_output.txt | cut -d' ' -f3-)

    # Guardar claves
    echo "$PRIVATE_KEY" > sparkle_private_key.pem
    echo "$PUBLIC_KEY" > sparkle_public_key.pem

    print_success "Claves generadas y guardadas"
    echo ""
    print_warning "IMPORTANTE: Guarda estas claves en un lugar seguro"
    echo ""
    echo "Clave pública (para Info.plist):"
    echo "$PUBLIC_KEY"
    echo ""
    echo "Clave privada (para GitHub Secret SPARKLE_PRIVATE_KEY):"
    echo "$PRIVATE_KEY"
    echo ""

    # Cleanup
    rm keys_output.txt
else
    PRIVATE_KEY=$(cat sparkle_private_key.pem)
    PUBLIC_KEY=$(cat sparkle_public_key.pem)
    print_info "Usando claves existentes"
fi

echo ""

# Paso 3: Verificar Info.plist
echo "Paso 3: Actualizar Info.plist"
echo "------------------------------"

CURRENT_PUBLIC_KEY=$(grep -A 1 "SUPublicEDKey" gula/Info.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

if [ "$CURRENT_PUBLIC_KEY" == "$PUBLIC_KEY" ]; then
    print_success "La clave pública en Info.plist ya está actualizada"
else
    print_warning "La clave pública en Info.plist necesita actualización"
    echo ""
    read -p "¿Quieres actualizar Info.plist automáticamente? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup
        cp gula/Info.plist gula/Info.plist.backup

        # Actualizar
        sed -i '' "s|<key>SUPublicEDKey</key>.*|<key>SUPublicEDKey</key>\n\t<string>$PUBLIC_KEY</string>|" gula/Info.plist

        print_success "Info.plist actualizado (backup en Info.plist.backup)"
    else
        print_warning "Por favor actualiza manualmente la clave pública en gula/Info.plist"
        echo "Clave pública: $PUBLIC_KEY"
    fi
fi

echo ""

# Paso 4: Configurar URLs
echo "Paso 4: Configurar URLs del repositorio"
echo "----------------------------------------"

read -p "Ingresa tu usuario de GitHub (ejemplo: rudoapps): " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    print_error "Usuario de GitHub no puede estar vacío"
    exit 1
fi

read -p "Ingresa el nombre del repositorio de releases (ejemplo: gula-releases): " RELEASES_REPO

if [ -z "$RELEASES_REPO" ]; then
    RELEASES_REPO="gula-releases"
    print_info "Usando nombre por defecto: $RELEASES_REPO"
fi

APPCAST_URL="https://raw.githubusercontent.com/$GITHUB_USER/$RELEASES_REPO/main/appcast.xml"

print_info "URL del appcast: $APPCAST_URL"

echo ""
read -p "¿Quieres actualizar SparkleUpdateService.swift con esta URL? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Backup
    cp gula/Presentation/Services/SparkleUpdateService.swift gula/Presentation/Services/SparkleUpdateService.swift.backup

    # Actualizar
    sed -i '' "s|TU_USUARIO|$GITHUB_USER|g" gula/Presentation/Services/SparkleUpdateService.swift

    print_success "SparkleUpdateService.swift actualizado"
else
    print_warning "Por favor actualiza manualmente las URLs en SparkleUpdateService.swift"
fi

echo ""

# Paso 5: Resumen y próximos pasos
echo "Resumen de configuración"
echo "========================"
echo ""
print_success "Usuario de GitHub: $GITHUB_USER"
print_success "Repositorio de releases: $RELEASES_REPO"
print_success "URL del appcast: $APPCAST_URL"
echo ""

echo "Próximos pasos:"
echo "---------------"
echo ""
echo "1️⃣  Configura los secrets en GitHub:"
echo "   - Ve a: Settings → Secrets and variables → Actions"
echo "   - Agrega estos secrets:"
echo ""
echo "   SPARKLE_PRIVATE_KEY:"
echo "   $PRIVATE_KEY"
echo ""
echo "   RELEASES_REPO_TOKEN:"
echo "   (genera un token en: Settings → Developer settings → Personal access tokens)"
echo ""
echo "   RELEASES_REPO_OWNER:"
echo "   $GITHUB_USER"
echo ""
echo "2️⃣  Crea el repositorio de releases:"
echo "   - Nombre: $RELEASES_REPO"
echo "   - Inicialízalo con el appcast.xml (ver SPARKLE_SETUP.md)"
echo ""
echo "3️⃣  Agrega Sparkle como dependencia en Xcode:"
echo "   - Abre gula.xcodeproj"
echo "   - Package Dependencies → + → https://github.com/sparkle-project/Sparkle"
echo ""
echo "4️⃣  Compila y prueba la app"
echo ""

print_success "¡Configuración completada!"
print_warning "No olvides hacer commit de los cambios (excepto las claves privadas)"
