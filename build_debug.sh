#!/bin/bash

# Script para compilar en Debug con firma adhoc
# Úsalo en lugar de Cmd+R en Xcode

set -e

echo "🔨 Compilando Gula en modo Debug..."
xcodebuild build \
  -project gula.xcodeproj \
  -scheme gula \
  -configuration Debug \
  CODE_SIGN_IDENTITY="-" \
  | xcpretty || true

echo "✅ Compilación completada"
echo "📱 Abriendo app..."
open /Users/fer/Library/Developer/Xcode/DerivedData/gula-ctstaehehvrnzycajgacqbakwcmx/Build/Products/Debug/gula.app

echo "✨ ¡Listo!"
