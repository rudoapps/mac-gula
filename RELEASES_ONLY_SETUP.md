# Configuración de Repositorio Solo para Releases

## 🎯 Enfoque: Repositorio Público para Distribución

Tu código fuente permanece **privado** en este repositorio local. El repositorio GitHub `rudoapps/mac-gula` será **solo para distribución** de releases.

## 📁 Archivos a subir al repositorio público

```
rudoapps/mac-gula/
├── appcast.xml           # Feed de actualizaciones
├── README.md            # Descripción de la app
└── .github/
    └── workflows/
        └── update-appcast.yml  # Workflow simplificado
```

## 🔧 Configuración del Repositorio Público

### 1. Archivos mínimos necesarios

**appcast.xml** ✅ (ya configurado)
**README.md** para tu repositorio público:

```markdown
# Gula - macOS Development Tool

Gula es una herramienta de desarrollo para macOS que te ayuda con la gestión de proyectos.

## 📥 Descarga

Descarga la última versión desde [Releases](https://github.com/rudoapps/mac-gula/releases).

## 🔄 Actualizaciones Automáticas

Gula incluye actualizaciones automáticas mediante Sparkle. La app te notificará cuando haya nuevas versiones disponibles.

## 📋 Requisitos del Sistema

- macOS 15.0 o superior
- Permisos de administrador para instalación

## 🛠 Instalación

1. Descarga el archivo DMG más reciente
2. Monta el DMG y arrastra Gula.app a Aplicaciones
3. Ejecuta Gula desde el Launchpad o Aplicaciones

---

🤖 Actualizaciones automáticas powered by [Sparkle](https://sparkle-project.org/)
```

### 2. Workflow Simplificado

En lugar de compilar, solo actualiza el appcast cuando subes releases manualmente.

## 🚀 Proceso de Release Manual

### Paso 1: Compilar localmente
```bash
# En tu repositorio privado
xcodebuild -project gula.xcodeproj -scheme gula -configuration Release archive -archivePath build/gula.xcarchive

# Exportar app
xcodebuild -exportArchive -archivePath build/gula.xcarchive -exportPath build -exportOptionsPlist ExportOptions.plist

# Crear DMG
create-dmg --volname "Gula 1.0.1" "Gula-1.0.1.dmg" build/
```

### Paso 2: Firmar DMG
```bash
./sign_update.sh Gula-1.0.1.dmg
```

### Paso 3: Crear release en GitHub
```bash
# Script automatizado que crearemos
./create_release.sh 1.0.1 Gula-1.0.1.dmg
```

## ✅ Ventajas de este enfoque

- **Código privado** permanece en tu máquina
- **Distribución pública** profesional
- **Control total** sobre qué y cuándo publicas
- **Sparkle funciona** perfectamente
- **GitHub Actions simples** (solo actualizaciones de appcast)

## 🔐 Seguridad

- Clave privada permanece en tu máquina local
- Solo subes DMG firmados al repositorio público
- GitHub no tiene acceso a tu código fuente

## 📝 Scripts que crearemos

1. `build_release.sh` - Compila y crea DMG localmente
2. `create_release.sh` - Sube a GitHub y actualiza appcast
3. Workflow mínimo para mantener appcast actualizado

¿Procedemos con esta configuración?