# Proceso de Release de Gula

Este documento explica cómo crear y publicar nuevas versiones de Gula con actualizaciones automáticas vía Sparkle.

## Conceptos Importantes

### Dos números de versión:

1. **MARKETING_VERSION** (CFBundleShortVersionString)
   - Versión que ven los usuarios: `1.0.5`, `1.0.6`, `2.0.0`
   - Se muestra en el diálogo de actualización
   - Se usa en el nombre del archivo: `Gula-1.0.6.dmg`

2. **CURRENT_PROJECT_VERSION** (CFBundleVersion)
   - Build number que usa Sparkle para comparar: `5`, `6`, `7`, `8`
   - **CRÍTICO:** Sparkle compara este número para detectar actualizaciones
   - Debe incrementarse en cada release

### Ejemplo de appcast.xml:

```xml
<item>
    <title>Gula 1.0.6</title>
    <sparkle:version>7</sparkle:version>  ← Build number (para comparación)
    <sparkle:shortVersionString>1.0.6</sparkle:shortVersionString>  ← Versión legible
</item>
```

**Cómo funciona:**
- App instalada tiene `sparkle:version = 6`
- Nueva versión tiene `sparkle:version = 7`
- Sparkle compara: `6 < 7` → ✅ Hay actualización!

---

## Proceso Automático (Recomendado)

El workflow de GitHub Actions se encarga de todo automáticamente.

### 1. Preparar la versión

Actualiza las versiones en Xcode:

```bash
# Opción A: Usar agvtool (herramienta de Apple)
xcrun agvtool new-marketing-version 1.0.7
xcrun agvtool new-version -all 8

# Opción B: Editar manualmente en Xcode
# - MARKETING_VERSION: 1.0.7
# - CURRENT_PROJECT_VERSION: 8
```

### 2. Commit y crear tag

```bash
git add .
git commit -m "Release v1.0.7"
git tag v1.0.7
git push origin main
git push origin v1.0.7
```

### 3. ¡Listo!

El workflow automáticamente:
1. ✅ Extrae el build number del proyecto (CURRENT_PROJECT_VERSION)
2. ✅ Compila la app en modo Release
3. ✅ Crea el archivo DMG
4. ✅ Firma el DMG con Sparkle
5. ✅ Actualiza `appcast.xml` con el **build number correcto**
6. ✅ Sube todo al repositorio `mac-gula-releases`
7. ✅ Crea el GitHub Release

### Verificar en GitHub Actions:

Ve a: https://github.com/rudoapps/mac-gula/actions

Busca el workflow "Release to Separate Repo" y verás logs como:

```
================================================
Generated appcast entry:
  Version (tag): 1.0.7
  Build Number:  8
  Marketing Ver: 1.0.7
================================================
```

---

## Proceso Manual (Para testing local)

Usa este script para crear versiones de prueba localmente:

```bash
./scripts/update_appcast.sh 1.0.7 8 "Descripción de cambios"
```

El script:
1. Actualiza las versiones en el proyecto
2. Compila la app
3. Crea el ZIP
4. Firma con Sparkle
5. Genera la entrada XML para el appcast

**Nota:** Después necesitas copiar manualmente:
- El ZIP a GitHub Releases
- La entrada XML al appcast.xml
- Hacer commit y push

---

## Checklist de Release

### Antes de crear el tag:

- [ ] Las versiones están actualizadas:
  - [ ] MARKETING_VERSION incrementada (ej: 1.0.6 → 1.0.7)
  - [ ] CURRENT_PROJECT_VERSION incrementada (ej: 6 → 7)
- [ ] Los cambios están en main
- [ ] La app compila sin errores

### Crear release:

```bash
git tag v1.0.7
git push origin v1.0.7
```

### Después del workflow:

- [ ] Workflow completó exitosamente
- [ ] Archivo DMG subido a `mac-gula-releases`
- [ ] `appcast.xml` actualizado con build number correcto
- [ ] GitHub Release creado

### Verificar actualización:

- [ ] Abrir app con versión anterior
- [ ] Ir a menú → "Buscar actualizaciones..."
- [ ] Debe mostrar la nueva versión disponible

---

## Troubleshooting

### La app no detecta actualización

**Problema:** App dice "Está actualizado" cuando hay versión nueva.

**Causa:** El `sparkle:version` no incrementó o es incorrecto.

**Solución:**
1. Verifica el appcast.xml en: https://raw.githubusercontent.com/rudoapps/mac-gula-releases/main/appcast.xml
2. Asegúrate que `sparkle:version` sea un número que incrementa (5, 6, 7...)
3. NO debe ser un string de versión ("1.0.5")

### El workflow falla al firmar

**Problema:** Error en step "Generate Sparkle signature"

**Solución:**
1. Verifica que el secret `SPARKLE_PRIVATE_KEY` esté configurado en GitHub
2. La clave privada está en: `~/mac-gula-releases/private_key.txt`
3. Copia el contenido completo (una línea de ~44 caracteres)

### Versiones incorrectas en appcast

**Problema:** El appcast tiene versiones mal formateadas.

**Solución:**
1. El workflow ahora extrae automáticamente el build number
2. Si necesitas corregir manualmente, edita `appcast.xml` en `mac-gula-releases`
3. Asegúrate que:
   - `sparkle:version` = build number (ej: 7)
   - `sparkle:shortVersionString` = versión string (ej: 1.0.6)

---

## Archivos Importantes

- **Workflow:** `.github/workflows/release-to-separate-repo.yml`
- **Script manual:** `scripts/update_appcast.sh`
- **Appcast:** `~/mac-gula-releases/appcast.xml`
- **Clave privada:** `~/mac-gula-releases/private_key.txt`
- **Info.plist:** `gula/Info.plist` (contiene clave pública de Sparkle)

---

## Ejemplo Completo

```bash
# 1. Actualizar versiones
xcrun agvtool new-marketing-version 1.0.7
xcrun agvtool new-version -all 8

# 2. Verificar
xcodebuild -showBuildSettings | grep -E "(MARKETING_VERSION|CURRENT_PROJECT_VERSION)" | head -2
# Output esperado:
#   CURRENT_PROJECT_VERSION = 8
#   MARKETING_VERSION = 1.0.7

# 3. Commit y tag
git add .
git commit -m "Release v1.0.7"
git tag v1.0.7
git push origin main
git push origin v1.0.7

# 4. ¡El workflow hace el resto!
```

---

## Referencias

- [Documentación de Sparkle](https://sparkle-project.org/)
- [GitHub Actions Workflow](.github/workflows/release-to-separate-repo.yml)
- [Script de actualización manual](scripts/update_appcast.sh)
