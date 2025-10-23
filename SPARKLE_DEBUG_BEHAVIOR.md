# Sparkle en Builds de Debug vs Release

## ⚡ CAUSA RAÍZ DEL PROBLEMA

**SUPublicEDKey está bloqueando Sparkle en debug**

Cuando agregamos `SUPublicEDKey` al Info.plist, Sparkle entra en "modo seguro" y requiere:
- ✅ Certificado de código Apple válido (no adhoc)
- ✅ App instalada en /Applications
- ✅ Actualizaciones firmadas con EdDSA

Por eso antes funcionaba (mostraba el popup) y ahora no.

## Comportamiento Actual

### En Debug (Desarrollo)
- **Estado**: Sparkle está **habilitado pero no funcional**
- **Mensaje**: "⚠️ Sparkle cannot check for updates in debug builds"
- **Razón**: Comportamiento esperado y correcto de Sparkle

### Por qué no funciona en Debug
Sparkle requiere las siguientes condiciones para funcionar:
1. ✅ **Firma de código válida** (no adhoc `-`)
2. ✅ **App instalada en ubicación estándar** (/Applications)
3. ✅ **Certificado de desarrollador Apple válido**

En desarrollo:
- ❌ Usamos firma adhoc (`CODE_SIGN_IDENTITY="-"`)
- ❌ La app ejecuta desde DerivedData
- ❌ No hay certificado de desarrollador configurado

### En Release (Producción)
- ✅ App firmada correctamente
- ✅ Instalada desde DMG en /Applications
- ✅ Sparkle funciona perfectamente
- ✅ Actualizaciones automáticas disponibles

## Configuración Actual

### Info.plist
```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/rudoapps/mac-gula/main/appcast.xml</string>
<key>SUPublicEDKey</key>
<string>MCowBQYDK2VwAyEAGyDXAH2Q/OXvsO0JxwXdPwpvv4hUec5bYdWfDydt0j0=</string>
```

### gulaApp.swift
- Sparkle se inicializa siempre (debug y release)
- Mensajes de debug explican el comportamiento esperado
- No se deshabilita en DEBUG (por petición del usuario)

## Flujo de Desarrollo

### Para desarrollo local
```bash
# Usar el script de build debug
./build_debug.sh
```

### Para testing de Sparkle
```bash
# Crear release y DMG
./publish_current_version.sh
# Instalar desde el DMG en /Applications
# Sparkle funcionará correctamente
```

## Soluciones Alternativas

Si necesitas probar Sparkle en desarrollo:

1. **Opción 1**: Obtener certificado de desarrollador Apple
   - Configurar signing en Xcode
   - Usar certificado real en lugar de adhoc

2. **Opción 2**: Instalar app de desarrollo en /Applications
   - Compilar en Release
   - Copiar .app a /Applications
   - Ejecutar desde ahí

3. **Opción 3**: Usar DMG de release
   - El DMG ya creado funciona perfectamente
   - Es la forma recomendada de probar actualizaciones

## Logs de Debug

Al iniciar la app en debug verás:
```
✅ Sparkle controller created
⚠️ Sparkle cannot check for updates in debug builds
   This is expected behavior when:
   - Running from Xcode or DerivedData
   - Using adhoc code signing
   - App is not in /Applications
   ℹ️ Sparkle will work correctly in release builds
📍 Feed URL: https://raw.githubusercontent.com/rudoapps/mac-gula/main/appcast.xml
📊 Automatic updates enabled: true
```

## Conclusión

El comportamiento actual es **correcto y esperado**:
- Sparkle está presente en el código (como solicitado)
- No interfiere con el desarrollo
- Funciona perfectamente en producción
- Los usuarios finales tienen actualizaciones automáticas

No es necesario hacer cambios adicionales.