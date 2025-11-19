# 🎁 PionierPuntos - App Móvil

Aplicación móvil Flutter para el sistema de gestión y acumulación de puntos PionierPuntos.

---

## 📖 Descripción

PionierPuntos es una aplicación móvil que permite a los usuarios acumular y redimir puntos a través de diferentes transacciones. La app ofrece una experiencia fluida y moderna para gestionar tu cuenta, consultar puntos y ver tu historial de transacciones.

### ✨ Características Principales

- 🔐 **Autenticación segura** con JWT
- 📧 **Registro con activación por email**
- 👤 **Gestión de perfil de usuario**
- 💳 **Consulta de puntos acumulados**
- 📊 **Historial de transacciones**
- 🎨 **Interfaz moderna y responsive**
- 🌐 **Detección de conectividad** con alertas bonitas
- 🔔 **Notificaciones en tiempo real**
- 🌙 **Modo claro/oscuro**

---

## 🚀 Tecnologías Utilizadas

- **Flutter** 3.x
- **Dart** 3.x
- **Provider** - State management
- **Go Router** - Navegación
- **Dio** - Cliente HTTP
- **Shared Preferences** - Almacenamiento local
- **Connectivity Plus** - Detección de red
- **Flutter Secure Storage** - Almacenamiento seguro

---

## 📋 Requisitos Previos

- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio / VS Code
- Android SDK (para Android)
- Xcode (para iOS, solo en macOS)
- Dispositivo físico o emulador

---

## 🚀 Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone [url-del-repositorio]
cd pionierpuntos
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar el entorno

Edita el archivo `lib/core/config/environment.dart` y actualiza la URL base del API:

```dart
class Environment {
  // URL de desarrollo
  static String get baseUrl {
    if (kDebugMode) {
      return 'http://191.98.147.53:8383'; // Tu IP de desarrollo
    }
    return 'https://api.pionierpuntos.com'; // URL de producción
  }
}
```

### 4. Ejecutar la aplicación

**En modo desarrollo:**

```bash
flutter run
```

**En dispositivo específico:**

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>
```

---

## 📱 Compilar para Producción

### Android APK

**APK Universal (más grande pero compatible con todos los dispositivos):**

```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

**APKs por arquitectura (más pequeños):**

```bash
flutter build apk --split-per-abi
```

Generará múltiples APKs en: `build/app/outputs/flutter-apk/`
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit)
- `app-x86_64-release.apk` (x86 64-bit)

### Android App Bundle (Para Google Play Store)

```bash
flutter build appbundle
```

El bundle se generará en: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Solo en macOS)

```bash
flutter build ios --release
```

---

## 🔧 Configuración de Firma (Android)

Para generar APKs firmados para producción:

### 1. Generar Keystore

```bash
keytool -genkey -v -keystore ~/keystore/pionierpuntos.jks -alias pionier -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Crear archivo `android/key.properties`

```properties
storePassword=tu_store_password
keyPassword=tu_key_password
keyAlias=pionier
storeFile=C:\\Users\\tu_usuario\\keystore\\pionierpuntos.jks
```

### 3. Configurar `android/app/build.gradle.kts`

El proyecto ya debe estar configurado para leer `key.properties`. Verifica que existe la sección `signingConfigs`.

### 4. Compilar APK firmado

```bash
flutter build apk --release
```

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── core/
│   ├── config/                  # Configuración (environment, constantes)
│   ├── constants/               # Constantes globales
│   ├── errors/                  # Manejo de excepciones
│   ├── network/                 # Cliente HTTP (Dio)
│   ├── theme/                   # Temas y estilos
│   ├── utils/                   # Utilidades y extensiones
│   └── widgets/                 # Widgets reutilizables
├── features/
│   ├── auth/                    # Módulo de autenticación
│   │   ├── data/
│   │   │   ├── datasources/     # Remote & Local datasources
│   │   │   ├── models/          # Modelos de datos
│   │   │   └── repositories/    # Implementación de repositorios
│   │   ├── domain/
│   │   │   ├── entities/        # Entidades de dominio
│   │   │   └── repositories/    # Interfaces de repositorios
│   │   └── presentation/
│   │       ├── providers/       # State management (Provider)
│   │       ├── screens/         # Pantallas
│   │       └── widgets/         # Widgets específicos
│   └── home/                    # Módulo de inicio
│       └── presentation/
│           ├── screens/
│           ├── views/           # Vistas del home
│           └── widgets/
└── routes/
    └── app_router.dart          # Configuración de rutas (GoRouter)
```

---

## 🎨 Arquitectura

El proyecto sigue **Clean Architecture** con las siguientes capas:

### 1. **Presentation Layer** (UI)
- Screens
- Widgets
- Providers (State Management)

### 2. **Domain Layer** (Lógica de negocio)
- Entities
- Repository Interfaces
- Use Cases

### 3. **Data Layer** (Acceso a datos)
- Models
- Datasources (Remote/Local)
- Repository Implementations

### Flujo de datos:

```
UI (Screen) 
  ↓
Provider (State Management)
  ↓
Repository Implementation
  ↓
Datasource (API / Local DB)
```

---

## 🔐 Funcionalidades de Autenticación

### Registro de Usuario

- Validación de formulario en tiempo real
- Tipos de documento: DNI, CE, Pasaporte
- Envío de email de activación
- Feedback visual de éxito/error

### Login

- Soporte para DNI o correo electrónico
- Detección de cuenta inactiva
- Opción de reenviar email de activación
- Gestión de sesión con tokens JWT
- Deep linking para activación

### Activación de Cuenta

- Click en enlace del email
- Redirección automática a la app
- Activación transparente

### Gestión de Sesión

- Token de acceso (24h)
- Refresh token
- Logout en dispositivo actual
- Logout en todos los dispositivos

---

## 🌐 Detección de Conectividad

La app incluye validación de conexión a Internet con:

- ✅ **Banner superior** que aparece cuando se pierde conexión
- ✅ **Alerta modal bonita** al iniciar sin Internet
- ✅ **Reconexión automática** cuando vuelve la red
- ✅ **Diseño premium** con animaciones suaves

### Uso del Banner de Conexión

Envuelve cualquier pantalla con `NoConnectionBanner`:

```dart
NoConnectionBanner(
  child: YourScreen(),
)
```

### Uso del Diálogo

Muestra el diálogo cuando necesites:

```dart
await NoConnectionDialog.show(
  context,
  onRetry: () {
    // Tu lógica de reintento
  },
);
```

---

## 🎨 Temas y Personalización

### Colores Principales

```dart
class AppColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF8B5CF6);
  static const accent = Color(0xFFEC4899);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}
```

### Cambiar Tema

Edita `lib/core/theme/app_theme.dart` para personalizar:
- Colores
- Tipografía
- Espaciados
- Bordes
- Sombras

---

## 🧪 Testing

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests con cobertura
flutter test --coverage

# Tests de integración
flutter test integration_test
```

### Estructura de Tests

```
test/
├── unit/              # Tests unitarios
├── widget/            # Tests de widgets
└── integration/       # Tests de integración
```

---

## 📱 Deep Linking

La app soporta deep links para:

### Activación de Cuenta

```
pionierpuntos://login
```

Se abre automáticamente después de activar la cuenta.

### Configuración en Android

El esquema `pionierpuntos://` ya está configurado en `android/app/src/main/AndroidManifest.xml`.

### Configuración en iOS

El esquema ya está configurado en `ios/Runner/Info.plist`.

---

## 🔒 Seguridad

- ✅ **Tokens JWT** con expiración
- ✅ **Flutter Secure Storage** para datos sensibles
- ✅ **HTTPS** en producción
- ✅ **Validación de datos** en cliente y servidor
- ✅ **Ofuscación de código** en release builds
- ✅ **ProGuard** habilitado para Android

---

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Navegación
  go_router: ^13.0.0
  
  # HTTP Client
  dio: ^5.4.0
  
  # Almacenamiento
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Conectividad
  connectivity_plus: ^6.1.1
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  
  # Utilidades
  intl: ^0.18.1
  package_info_plus: ^5.0.1
```

---

## 🐛 Debugging

### Logs

La app incluye logging detallado. Para ver logs:

```bash
flutter logs
```

### DevTools

Abre Flutter DevTools:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Debug Mode vs Release

- **Debug:** Incluye logs, hot reload, DevTools
- **Profile:** Para análisis de rendimiento
- **Release:** Optimizado, sin debug info

---

## 📊 Performance

### Tips de Optimización

1. **Imágenes:** Usa formatos optimizados (WebP, AVIF)
2. **Lazy Loading:** Carga datos bajo demanda
3. **Caché:** Usa `cached_network_image` para imágenes
4. **Build Methods:** Mantén widgets pequeños y reutilizables
5. **Async:** Usa `FutureBuilder` / `StreamBuilder` correctamente

---

## 🚀 Despliegue

### Google Play Store

1. Generar App Bundle firmado
2. Crear cuenta de desarrollador
3. Subir a Play Console
4. Completar información de la app
5. Enviar para revisión

### Apple App Store

1. Generar build de iOS
2. Subir a App Store Connect
3. Completar información de la app
4. Enviar para revisión

---

## 📞 Soporte y Contribución

Para reportar bugs o solicitar nuevas funcionalidades:

- Crear un issue en el repositorio
- Contactar al equipo de desarrollo

**Desarrollador:** Wilder Rojas  
**Versión:** 1.0.0  
**Última actualización:** 19 de Noviembre, 2025

---

## 📝 Changelog

### Versión 1.0.0 (2025-11-19)

- ✅ Implementación de autenticación completa
- ✅ Sistema de registro y activación por email
- ✅ Gestión de sesión con JWT
- ✅ Detección de conectividad con UI premium
- ✅ Deep linking para activación
- ✅ Arquitectura Clean Architecture
- ✅ State management con Provider
- ✅ Navegación con GoRouter
- ✅ Temas claro/oscuro
- ✅ Validación de formularios
- ✅ Manejo robusto de errores
- ✅ UI/UX moderna y responsive

---

## 🔜 Próximas Funcionalidades

- 💳 Consulta de saldo de puntos
- 📊 Historial detallado de transacciones
- 🎁 Catálogo de recompensas
- 🔔 Notificaciones push
- 📸 Escaneo de códigos QR
- 👤 Edición de perfil
- 🔐 Cambio de contraseña
- 🌐 Soporte multiidioma

---

## 📄 Licencia

Este proyecto es propiedad de [Tu Empresa]. Todos los derechos reservados.

---

**¿Listo para compilar?**

```bash
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk` 🎉
