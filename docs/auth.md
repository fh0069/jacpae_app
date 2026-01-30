# Autenticación con Supabase y MFA TOTP

## Resumen

Este proyecto implementa autenticación segura utilizando Supabase con **MFA (Multi-Factor Authentication) TOTP obligatorio**. Todos los usuarios deben completar la verificación en dos pasos para acceder a la aplicación.

## Configuración de Supabase

### Configuración MFA en Supabase Dashboard

1. **TOTP**: Habilitado ✅
2. **SMS MFA**: Deshabilitado (requiere plan Pro)
3. **Máximo factores por usuario**: 1
4. **Enhanced MFA Security**: ON (las sesiones AAL1 expiran en 15 minutos)

### Políticas de Seguridad

- **No hay signups desde la app**: Los usuarios se crean manualmente en Supabase Dashboard
- **Solo anon key en cliente**: La service_role key NUNCA se expone en el código del cliente
- **AAL2 obligatorio**: Los usuarios no pueden acceder a la app sin completar MFA

## Flujo de Autenticación

### 1. Login Inicial

```
Usuario → Login Screen
  ↓
  Ingresa email + password
  ↓
  AuthService.signInWithPassword()
  ↓
  ¿Tiene factor TOTP?
  ├─ NO → MFA Enroll Screen
  └─ SÍ → ¿Está en AAL2?
      ├─ NO → MFA Verify Screen
      └─ SÍ → Home Screen
```

### 2. MFA Enrollment (Primera vez)

```
MFA Enroll Screen
  ↓
  AuthService.enrollTOTP()
  ↓
  Muestra QR Code + Secret
  ↓
  Usuario escanea con app autenticadora
  ↓
  Ingresa código de 6 dígitos
  ↓
  AuthService.verifyMFA()
  ↓
  Sesión elevada a AAL2
  ↓
  Home Screen
```

### 3. MFA Verification (Logins subsecuentes)

```
MFA Verify Screen
  ↓
  AuthService.challengeAndVerifyMFA()
  ↓
  Usuario ingresa código de 6 dígitos
  ↓
  Sesión elevada a AAL2
  ↓
  Home Screen
```

## Niveles de Aseguramiento (AAL)

### AAL1 (Password Only)
- Usuario autenticado solo con email/password
- **NO tiene acceso a la aplicación**
- Debe completar MFA para elevar a AAL2
- Sesión expira en 15 minutos si no se verifica MFA (Enhanced MFA Security)

### AAL2 (Password + MFA)
- Usuario autenticado con email/password + TOTP
- **Tiene acceso completo a la aplicación**
- Sesión persiste según configuración de Supabase

## Guards de Navegación (GoRouter)

El router implementa redirecciones automáticas basadas en el estado de autenticación:

| Estado de Usuario | Ruta Solicitada | Acción |
|------------------|----------------|---------|
| No autenticado | Cualquiera | → `/` (Login) |
| AAL1 (sin MFA) | Cualquiera excepto `/mfa/*` | → `/mfa/verify` |
| AAL1 (sin MFA) | `/mfa/enroll` o `/mfa/verify` | ✅ Permitido |
| AAL2 (con MFA) | `/` o `/mfa/*` | → `/home` |
| AAL2 (con MFA) | Rutas privadas | ✅ Permitido |

## Estructura de Archivos

```
lib/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── providers/
│       │   │   └── auth_provider.dart      # Riverpod providers
│       │   └── services/
│       │       └── auth_service.dart       # Lógica de auth
│       └── presentation/
│           └── screens/
│               ├── login_screen.dart       # Login con email/password
│               ├── mfa_enroll_screen.dart  # Configurar TOTP
│               └── mfa_verify_screen.dart  # Verificar TOTP
├── core/
│   ├── router/
│   │   └── app_router.dart                 # Router con guards
│   └── constants/
│       └── app_constants.dart              # Rutas
└── main.dart                               # Inicialización Supabase
```

## Cómo Ejecutar la Aplicación

### Requisitos Previos

1. Tener un proyecto de Supabase configurado
2. Habilitar TOTP en Supabase Dashboard (Authentication → Multi-Factor Authentication)
3. Crear usuarios manualmente en Supabase Dashboard (Authentication → Users)

### Comandos de Ejecución

```bash
# Desarrollo
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key

# Producción (ejemplo con variables de entorno)
flutter build apk \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

**Importante**: NUNCA hagas commit de las credenciales en el repositorio. Usa variables de entorno o archivos `.env` (y añádelos a `.gitignore`).

## Crear Usuario Manualmente en Supabase

1. Ve a Supabase Dashboard → Authentication → Users
2. Click en "Add user" → "Create new user"
3. Ingresa:
   - **Email**: email@ejemplo.com
   - **Password**: contraseña segura (mínimo 6 caracteres)
   - **Auto Confirm User**: ✅ (para evitar confirmación de email)
4. Click en "Create user"

## Aplicaciones Autenticadoras Recomendadas

Los usuarios pueden usar cualquier app compatible con TOTP:

- **Google Authenticator** (iOS, Android)
- **Authy** (iOS, Android, Desktop)
- **Microsoft Authenticator** (iOS, Android)
- **1Password** (multiplataforma, premium)
- **Bitwarden** (multiplataforma, open source)

## Proceso de Login Completo (Ejemplo)

### Primera vez (nuevo usuario)

1. Usuario creado manualmente en Supabase: `usuario@ejemplo.com`
2. Usuario abre la app → Login Screen
3. Ingresa email + password → Login exitoso (AAL1)
4. App detecta que no tiene factor TOTP → redirige a MFA Enroll
5. Usuario ve QR code y código secreto
6. Usuario escanea QR con Google Authenticator
7. Google Authenticator muestra código de 6 dígitos
8. Usuario ingresa código → Verificación exitosa (AAL2)
9. App redirige a Home Screen ✅

### Logins subsecuentes

1. Usuario abre la app → Login Screen
2. Ingresa email + password → Login exitoso (AAL1)
3. App detecta que ya tiene factor TOTP → redirige a MFA Verify
4. Usuario abre Google Authenticator
5. Ingresa código de 6 dígitos → Verificación exitosa (AAL2)
6. App redirige a Home Screen ✅

## Manejo de Errores Comunes

### "Invalid login credentials"
- **Causa**: Email o password incorrectos
- **Solución**: Verificar credenciales en Supabase Dashboard

### "Email not confirmed"
- **Causa**: Usuario no confirmó email
- **Solución**: Marcar "Auto Confirm User" al crear usuario

### "Código inválido" en MFA
- **Causa**: Código TOTP expirado o incorrecto
- **Solución**: Los códigos TOTP cambian cada 30 segundos. Esperar código nuevo.

### "Supabase credentials not found!"
- **Causa**: No se pasaron las variables dart-define
- **Solución**: Ejecutar con `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## APIs de AuthService

```dart
// Sign in
final response = await authService.signInWithPassword(
  email: 'usuario@ejemplo.com',
  password: 'password123',
);

// Check if has TOTP
final hasTOTP = await authService.hasTOTPFactor();

// Enroll TOTP
final enrollResponse = await authService.enrollTOTP(
  issuer: 'JacPae App',
);
// enrollResponse.totp.qrCode (URI para QR)
// enrollResponse.totp.secret (código manual)
// enrollResponse.id (factor ID)

// Verify MFA
final verifyResponse = await authService.challengeAndVerifyMFA(
  factorId: factorId,
  code: '123456',
);

// Check AAL level
final isAAL2 = authService.isAAL2; // true si está verificado

// Sign out
await authService.signOut();
```

## Seguridad

### ✅ Implementado

- Autenticación con Supabase (email/password)
- MFA TOTP obligatorio
- Guards de navegación (no se puede saltear MFA)
- Solo anon key en cliente
- PKCE flow para auth
- Enhanced MFA Security (AAL1 expira en 15 min)

### ⚠️ Pendiente (Fases Futuras)

- Rate limiting en endpoints
- Recuperación de cuenta (si pierde app autenticadora)
- Registro desde la app (actualmente manual)
- Refresh token automático
- Biometría local (opcional)

## Notas Importantes

1. **No hay backend FastAPI en esta fase**: Solo autenticación con Supabase
2. **No hay base de datos todavía**: Los datos de la app son mocks
3. **TOTP es el único método MFA**: SMS requiere plan Pro
4. **Un solo factor por usuario**: Configuración actual de Supabase
5. **Los usuarios se crean manualmente**: No hay signup en la app

## Recursos

- [Supabase MFA Docs](https://supabase.com/docs/guides/auth/auth-mfa)
- [TOTP Specification (RFC 6238)](https://datatracker.ietf.org/doc/html/rfc6238)
- [supabase_flutter Package](https://pub.dev/packages/supabase_flutter)

---

**Fecha de última actualización**: 2025-01-30
**Versión de la app**: 1.0.0 (PHASE 2)
**Autor**: Claude Sonnet 4.5
