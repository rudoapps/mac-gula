#!/bin/bash
# Script para firmar actualizaciones de Sparkle

if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_a_firmar>"
    exit 1
fi

ARCHIVO="$1"
PRIVATE_KEY="sparkle_private_key.pem"

if [ ! -f "$PRIVATE_KEY" ]; then
    echo "Error: No se encontró la clave privada $PRIVATE_KEY"
    exit 1
fi

if [ ! -f "$ARCHIVO" ]; then
    echo "Error: No se encontró el archivo $ARCHIVO"
    exit 1
fi

# Generar firma EdDSA
SIGNATURE=$(openssl dgst -sha256 -sign "$PRIVATE_KEY" "$ARCHIVO" | base64)

echo "Archivo: $ARCHIVO"
echo "Tamaño: $(stat -f%z "$ARCHIVO") bytes"
echo "Firma EdDSA: $SIGNATURE"