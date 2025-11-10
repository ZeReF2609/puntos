# ✅ Solución al Error de Conexión

## 📋 Resumen de Cambios Realizados

### 1. ✅ Permisos de Android Agregados
**Archivo**: `android/app/src/main/AndroidManifest.xml`

Se agregaron los permisos necesarios:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 2. ✅ Configuración de Seguridad de Red
**Archivo**: `android/app/src/main/res/xml/network_security_config.xml` (NUEVO)

Se creó la configuración para permitir tráfico HTTP (cleartext) en desarrollo:
- localhost
- 10.0.2.2 (IP de Android Emulator)
- 127.0.0.1
- 192.168.1.100 (cambia por tu IP local si usas dispositivo físico)

### 3. ✅ Actualización de AndroidManifest
Se agregaron las configuraciones:
```xml
android:usesCleartextTraffic="true"
android:networkSecurityConfig="@xml/network_security_config"
```

### 4. ✅ Formulario de Registro Actualizado
**Archivo**: `lib/features/auth/presentation/screens/register_screen.dart`

Ahora incluye todos los campos requeridos por la API:
- ✅ Tipo de Documento (dropdown con DNI, CE, RUC, PASAPORTE)
- ✅ Número de Documento
- ✅ Nombre
- ✅ Apellido Paterno
- ✅ Apellido Materno
- ✅ Correo Electrónico
- ✅ Teléfono
- ✅ Contraseña
- ✅ Confirmar Contraseña

### 5. ✅ Configuración de Entorno
**Archivo**: `lib/core/config/environment.dart` (NUEVO)

Sistema automático de URLs según plataforma:
- Android Emulator: `http://10.0.2.2:8383`
- iOS Simulator: `http://localhost:8383`
- Dispositivo físico: Opción de IP local configurable

### 6. ✅ Widget de Debug
**Archivo**: `lib/core/widgets/environment_info.dart` (NUEVO)

Widget en Configuración (solo en modo Debug) para:
- Ver la URL actual
- Cambiar entre URL automática e IP local
- Debug de conexión

## 🚀 Pasos para Aplicar los Cambios

### Opción 1: Hot Restart (Recomendado)
1. En VS Code presiona: `Ctrl + Shift + F5`
2. O en la consola de Flutter: `R` (Hot Restart completo)

### Opción 2: Reconstruir la App
```powershell
cd pionierpuntos
flutter clean
flutter pub get
flutter run
```

### Opción 3: Reinstalar en el dispositivo
```powershell
flutter run --uninstall-first
```

## 🧪 Verificación

### 1. Verificar que el servidor esté corriendo
```powershell
# Terminal 1 - Iniciar servidor
cd pp_node
npm start
```

### 2. Probar la conexión desde PowerShell
```powershell
# Debería responder con status 201
Invoke-WebRequest -Uri "http://localhost:8383/api/v1/auth/register" -Method POST -ContentType "application/json" -Body '{"tipoDocumento":"01","numDocumento":"12345678","nombre":"Test","apePaterno":"User","apeMaterno":"Demo","correo":"test@test.com","telefono":"987654321","password":"Test123"}'
```

### 3. En la App Flutter
1. Inicia la app en el emulador
2. Ve a la pantalla de Registro
3. Llena todos los campos
4. Presiona "Crear Cuenta"
5. Verifica en la consola los logs de Dio:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REQUEST[POST] => PATH: http://10.0.2.2:8383/api/v1/auth/register
Headers: {Content-Type: application/json, Accept: application/json}
Data: {tipoDocumento: 01, numDocumento: 12345678, ...}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## ❓ Solución de Problemas

### Si el error persiste:

#### 1. Verifica que los archivos se hayan guardado
```powershell
# Verifica que existe el archivo de configuración
ls android\app\src\main\res\xml\network_security_config.xml
```

#### 2. Limpia y reconstruye
```powershell
flutter clean
cd android
.\gradlew clean
cd ..
flutter pub get
flutter run
```

#### 3. Verifica la IP si usas dispositivo físico
```powershell
ipconfig
# Busca tu IPv4 en la sección WiFi
# Actualiza en environment.dart:
# static const String localIpUrl = 'http://TU_IP:8383';
# static bool useLocalIp = true;
```

#### 4. Verifica el Firewall de Windows
```powershell
# Agrega regla para permitir conexiones al puerto 8383
New-NetFirewallRule -DisplayName "Node.js API Dev" -Direction Inbound -LocalPort 8383 -Protocol TCP -Action Allow
```

## 📱 Para Dispositivo Físico

1. Conecta el dispositivo a la misma red WiFi
2. Obtén tu IP local:
   ```powershell
   ipconfig
   ```
3. Actualiza en `lib/core/config/environment.dart`:
   ```dart
   static const String localIpUrl = 'http://192.168.1.XXX:8383';
   static bool useLocalIp = true;
   ```
4. Actualiza en `android/app/src/main/res/xml/network_security_config.xml`:
   ```xml
   <domain includeSubdomains="true">192.168.1.XXX</domain>
   ```
5. Reconstruye la app:
   ```powershell
   flutter run --uninstall-first
   ```

## ✨ Verificación Final

✅ Servidor corriendo en puerto 8383
✅ Permisos de Internet en AndroidManifest
✅ Configuración de red para HTTP cleartext
✅ URL correcta según plataforma (10.0.2.2 para emulador)
✅ App reiniciada con Hot Restart o flutter run
✅ Logs de Dio mostrando las peticiones

## 🎯 Próximos Pasos

Una vez que el registro funcione:
1. El login automático funcionará con el número de documento
2. Podrás navegar a la pantalla Home
3. Los tokens se guardarán en SharedPreferences
4. La sesión persistirá entre cierres de app
