# 🚀 Gula Release Process with GitHub & Sparkle

Esta guía explica cómo publicar nuevas versiones de Gula usando GitHub Releases y Sparkle para actualizaciones automáticas.

## 📋 Configuración inicial (solo una vez)

### 1. Configurar el repositorio
Reemplaza `YOUR_USERNAME/YOUR_REPO` en estos archivos con tu información real:
- `gula.xcodeproj/project.pbxproj` (líneas con `INFOPLIST_KEY_SUFeedURL`)
- `appcast.xml` (todas las URLs de GitHub)

### 2. Generar claves de firma Sparkle
```bash
# Descargar Sparkle tools
curl -L -o sparkle.tar.xz https://github.com/sparkle-project/Sparkle/releases/latest/download/Sparkle-for-Swift-Package-Manager.tar.xz
tar -xf sparkle.tar.xz

# Generar claves Ed25519
./bin/generate_keys
```

Esto generará:
- **Clave pública**: Agrégala a tu proyecto Xcode en `INFOPLIST_KEY_SUPublicEDKey`
- **Clave privada**: Guárdala como secret de GitHub `SPARKLE_PRIVATE_KEY`

### 3. Agregar secrets de GitHub
En tu repositorio GitHub, ve a Settings → Secrets and Variables → Actions:

- `SPARKLE_PRIVATE_KEY`: Tu clave privada de Sparkle (sin espacios ni saltos de línea)

### 4. Actualizar la clave pública en Xcode
En `gula.xcodeproj/project.pbxproj`, reemplaza:
```
INFOPLIST_KEY_SUPublicEDKey = "your-public-key-here";
```
Con tu clave pública real.

## 🎯 Proceso de release

### Método 1: Release automático completo
```bash
# 1. Incrementar versión en Xcode
# Marketing Version: 1.1
# Current Project Version: 3

# 2. Commit cambios
git add .
git commit -m "Bump version to 1.1"
git push

# 3. Crear tag y push
git tag v1.1
git push origin v1.1
```

**¡Eso es todo!** GitHub Actions se encargará de:
- ✅ Compilar la app
- ✅ Crear el DMG
- ✅ Firmar con Sparkle
- ✅ Crear GitHub Release
- ✅ Actualizar appcast.xml automáticamente

### Método 2: Release manual
Si prefieres más control:

```bash
# 1. Compilar
xcodebuild -project gula.xcodeproj -scheme gula -configuration Release -archivePath build/gula.xcarchive archive

# 2. Exportar
xcodebuild -exportArchive -archivePath build/gula.xcarchive -exportPath build/export -exportOptionsPlist ExportOptions.plist

# 3. Crear DMG
create-dmg --volname "Gula 1.1" "Gula-1.1.dmg" "build/export/"

# 4. Firmar con Sparkle
./bin/sign_update "Gula-1.1.dmg" sparkle_private_key

# 5. Subir a GitHub Release manualmente
```

## 📁 Estructura de archivos después del setup

```
tu-repositorio/
├── .github/
│   └── workflows/
│       └── release.yml          # GitHub Actions workflow
├── gula.xcodeproj/
│   └── project.pbxproj          # Configuración con URLs de GitHub
├── appcast.xml                  # Feed de actualizaciones (se actualiza automáticamente)
├── RELEASE.md                   # Esta guía
└── [resto del proyecto...]
```

## 🔄 Flujo de actualización para usuarios

1. **Usuario abre Gula** → Sparkle verifica automáticamente updates
2. **Si hay nueva versión** → Se muestra notificación
3. **Usuario acepta** → Se descarga DMG desde GitHub Releases
4. **Instalación automática** → Sparkle instala la nueva versión

## 🛠 URLs importantes

Una vez configurado con tu información:

- **Feed de actualizaciones**: `https://github.com/TU_USUARIO/TU_REPO/raw/main/appcast.xml`
- **Releases de GitHub**: `https://github.com/TU_USUARIO/TU_REPO/releases`
- **DMG download**: `https://github.com/TU_USUARIO/TU_REPO/releases/download/vX.X/Gula-X.X.dmg`

## 🚨 Troubleshooting

### Error: "No se pueden verificar actualizaciones"
- Verifica que el `appcast.xml` esté accesible públicamente
- Confirma que las URLs en el proyecto apunten a tu repositorio

### Error: "Firma inválida"
- Verifica que la clave privada de GitHub Secrets sea correcta
- La clave no debe tener espacios ni saltos de línea adicionales

### Error en GitHub Actions
- Revisa que el proyecto compile correctamente en local
- Verifica que todos los secrets estén configurados

## 📊 Métricas de releases

GitHub Actions proporcionará automáticamente:
- ✅ Logs de compilación
- ✅ Tamaño del DMG
- ✅ Firma Sparkle
- ✅ Assets descargables
- ✅ Release notes automáticas

## 🎉 ¡Listo!

Con esta configuración, tus usuarios recibirán automáticamente notificaciones de nuevas versiones y podrán actualizar con un solo clic. El proceso de release se reduce a crear un tag de Git.