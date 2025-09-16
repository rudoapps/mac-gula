# Configuración de Sparkle para Gula

## ✅ Pasos Completados

1. **Archivo appcast.xml creado** ✓
2. **URLs de Sparkle configuradas en el proyecto** ✓
3. **Claves de firma generadas** ✓
4. **GitHub Actions configurado** ✓

## 🔑 Pasos Pendientes

### 1. Subir archivos al repositorio

Sube estos archivos a tu repositorio `https://github.com/rudoapps/mac-gula`:

```bash
git add appcast.xml .github/workflows/release.yml
git commit -m "Add Sparkle configuration"
git push origin main
```

### 2. Configurar Secrets en GitHub

Ve a tu repositorio en GitHub → Settings → Secrets and variables → Actions, y añade:

**SPARKLE_PRIVATE_KEY**: 
```
-----BEGIN PRIVATE KEY-----
MC4CAQAwBQYDK2VwBCIEIB8vI2Q4NjQ2NjQ2NjQ2NjQ2NjQ2NjQ2NjQ2NjQ2NjQ2
-----END PRIVATE KEY-----
```
*(Usa el contenido del archivo `sparkle_private_key.pem` que se generó)*

### 3. Mantener la Clave Privada Segura

⚠️ **IMPORTANTE**: 
- Guarda el archivo `sparkle_private_key.pem` en un lugar seguro
- NO lo subas al repositorio
- Añádelo a tu `.gitignore`

```bash
echo "sparkle_private_key.pem" >> .gitignore
```

### 4. Crear tu Primera Release

Para crear una nueva versión:

```bash
# 1. Actualiza la versión en tu proyecto Xcode
# 2. Haz commit de los cambios
git add .
git commit -m "Release v1.0.1"

# 3. Crea un tag
git tag v1.0.1
git push origin v1.0.1
```

El GitHub Action se ejecutará automáticamente y:
- Compilará la app
- Creará un DMG
- Firmará el DMG con Sparkle
- Actualizará el appcast.xml
- Creará la release en GitHub

### 5. Verificar el Funcionamiento

1. **Instala la app** desde la nueva release
2. **Crea otra versión** (v1.0.2) siguiendo el paso 4
3. **Prueba la actualización**: La app debería detectar automáticamente la nueva versión

## 📋 Configuración Actual

- **Feed URL**: `https://github.com/rudoapps/mac-gula/raw/main/appcast.xml`
- **Clave Pública**: `MCowBQYDK2VwAyEAGyDXAH2Q/OXvsO0JxwXdPwpvv4hUec5bYdWfDydt0j0=`
- **Versión Mínima**: macOS 15.0

## 🛠 Comandos Útiles

**Firmar manualmente un archivo**:
```bash
./sign_update.sh mi_archivo.dmg
```

**Ver el contenido del appcast**:
```bash
curl -s https://github.com/rudoapps/mac-gula/raw/main/appcast.xml
```

**Verificar la configuración de Sparkle**:
```bash
# Buscar en el proyecto las configuraciones
grep -r "SUFeedURL\|SUPublicEDKey" gula.xcodeproj/
```

## 🚨 Solución de Problemas

**La app no detecta actualizaciones**:
1. Verifica que el appcast.xml esté accesible online
2. Comprueba que la clave pública sea correcta
3. Verifica que la firma del DMG sea válida

**Error de compilación en GitHub Actions**:
1. Verifica que el esquema "gula" esté marcado como "Shared" en Xcode
2. Asegúrate de que no hay dependencias de signing que requieran certificados

**Actualizaciones no se instalan**:
1. Verifica que el usuario tenga permisos de escritura en Applications
2. Comprueba que la versión en Info.plist sea mayor que la actual