# Guía de Conexión API - PionierPuntos

## 🔧 Configuración según la plataforma

### 📱 Android Emulator
- **URL configurada**: `http://10.0.2.2:8383`
- **Razón**: `10.0.2.2` es la IP especial que Android Emulator usa para referirse a `localhost` de tu máquina host
- **No requiere cambios adicionales**

### 📱 Android - Dispositivo Físico
1. Conecta tu dispositivo a la misma red WiFi que tu PC
2. Encuentra tu IP local:
   ```powershell
   ipconfig
   ```
   Busca la dirección IPv4 de tu conexión WiFi (ej: `192.168.1.100`)

3. Actualiza en `lib/core/config/environment.dart`:
   ```dart
   static const String localIpUrl = 'http://TU_IP_LOCAL:8383';
   static bool useLocalIp = true;
   ```

4. O cambia desde la app:
   - Ve a Configuración
   - En la sección "Desarrollo"
   - Activa "Usar IP Local"
   - Reinicia la app

### 🍎 iOS Simulator
- **URL configurada**: `http://localhost:8383`
- **No requiere cambios adicionales**

### 🍎 iOS - Dispositivo Físico
- Igual que Android dispositivo físico (usar IP local)

### 💻 Web / Desktop
- **URL configurada**: `http://localhost:8383`
- **No requiere cambios adicionales**

## 🚀 Verificar que el servidor esté corriendo

1. Asegúrate de que tu servidor Node.js esté ejecutándose:
   ```powershell
   cd pp_node
   npm start
   ```

2. Verifica que responda en:
   - http://localhost:8383/api/v1

3. Prueba la API de registro:
   ```powershell
   curl -X POST http://localhost:8383/api/v1/auth/register `
     -H "Content-Type: application/json" `
     -d '{
       "tipoDocumento": "01",
       "numDocumento": "12345678",
       "nombre": "Juan",
       "apePaterno": "Pérez",
       "apeMaterno": "García",
       "correo": "juan.perez@email.com",
       "telefono": "987654321",
       "password": "MiPassword123"
     }'
   ```

## 🐛 Debugging

### Ver logs en la consola
Los logs de Dio mostrarán:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REQUEST[POST] => PATH: http://10.0.2.2:8383/api/v1/auth/register
Headers: {Content-Type: application/json, Accept: application/json}
Data: {tipoDocumento: 01, numDocumento: 12345678, ...}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Errores comunes

#### ❌ "SocketException: Failed host lookup"
- El servidor no está corriendo
- La URL es incorrecta
- **Solución**: Verifica que el servidor esté en el puerto 8383

#### ❌ "Connection refused"
- El servidor no está escuchando en el puerto
- **Solución**: Reinicia el servidor Node.js

#### ❌ "Timeout"
- El servidor está muy lento
- Hay un firewall bloqueando
- **Solución**: Aumenta el timeout o revisa el firewall

#### ❌ Error 404
- La ruta del endpoint es incorrecta
- **Solución**: Verifica que la ruta sea `/api/v1/auth/register`

## 🔄 Cambiar entre entornos

### Opción 1: Desde código
Edita `lib/core/config/environment.dart`:
```dart
static bool useLocalIp = true; // Usar IP local en lugar de 10.0.2.2
```

### Opción 2: Desde la app (solo en modo Debug)
1. Inicia sesión (o ve a Configuración)
2. Busca la sección "Desarrollo"
3. Verás la configuración actual de URLs
4. Activa/desactiva "Usar IP Local"
5. Reinicia la app

## 📝 Estructura de la API de Registro

```json
{
  "tipoDocumento": "01",    // 01=DNI, 02=CE, 03=RUC, 04=PASAPORTE
  "numDocumento": "12345678",
  "nombre": "Juan",
  "apePaterno": "Pérez",
  "apeMaterno": "García",
  "correo": "juan.perez@email.com",
  "telefono": "987654321",
  "password": "MiPassword123"
}
```

## ✅ Checklist de verificación

- [ ] Servidor Node.js corriendo en puerto 8383
- [ ] URL correcta según plataforma
- [ ] Red WiFi compartida (si usas dispositivo físico)
- [ ] Firewall permite conexiones al puerto 8383
- [ ] La app muestra los logs de conexión en la consola
- [ ] Formulario de registro completo con todos los campos

## 🔧 Configuración del Firewall (Windows)

Si usas un dispositivo físico y no se conecta:

```powershell
# Permitir conexiones entrantes en el puerto 8383
New-NetFirewallRule -DisplayName "Node.js API" -Direction Inbound -LocalPort 8383 -Protocol TCP -Action Allow
```
