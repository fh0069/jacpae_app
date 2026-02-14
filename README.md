# Jacpae App - PHASE 2: Authentication

> **✅ PHASE 2 - Real Authentication Implemented**
>
> This phase includes full Supabase authentication with **mandatory MFA TOTP**. Users must complete two-factor authentication to access the app.

## 🎯 Project Overview

Flutter mobile application (Android/iOS) for company-client communication built with Material 3 design.

**Current Phase:** PHASE 2 - Authentication (Supabase + MFA)
**Version:** 1.0.0+1
**Status:** ✅ Authentication fully functional

---

## 📋 What's Implemented

### ✅ PHASE 2 - Authentication (NEW)
- **Supabase authentication** (email/password)
- **Mandatory MFA TOTP** (Google Authenticator, Authy, etc.)
- **AAL2 enforcement** (users cannot access app without MFA)
- **Auth state management** with Riverpod
- **Navigation guards** in GoRouter
- **MFA enrollment flow** (first-time users)
- **MFA verification flow** (returning users)
- **Logout functionality**
- **Enhanced MFA Security** (AAL1 sessions expire in 15 minutes)

### ✅ PHASE 1 - UI & Scaffolding
- Complete UI for all screens with Material 3
- Feature-based modular architecture
- Navigation system with go_router
- Mock data for all features
- Reusable widget components
- Global theming system

### ❌ NOT Implemented (Future Phases)
- Backend API calls (MariaDB)
- Payment gateway integration (Redsys)
- Push notifications (Firebase/OneSignal)
- Document downloads
- Real data persistence

---

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Main app widget
├── core/                              # Core functionality
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants
│   ├── router/
│   │   └── app_router.dart            # Navigation configuration
│   ├── services/
│   │   ├── api_service.dart           # API service placeholder (TODO PHASE 2)
│   │   └── supabase_service.dart      # Supabase placeholder (TODO PHASE 2)
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette
│   │   └── app_theme.dart             # Material 3 theme
│   └── widgets/
│       ├── custom_app_bar.dart        # Reusable app bar
│       ├── custom_button.dart         # Reusable button
│       └── custom_text_field.dart     # Reusable text field
├── features/                          # Feature modules
│   ├── auth/
│   │   ├── data/services/
│   │   │   └── auth_service.dart      # Auth placeholder (TODO PHASE 2)
│   │   └── presentation/screens/
│   │       └── login_screen.dart      # Login UI
│   ├── home/
│   │   ├── data/models/
│   │   │   └── dashboard_item.dart    # Dashboard model
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart   # Home/Dashboard
│   │       └── widgets/
│   │           └── dashboard_card.dart
│   ├── consultas/
│   │   ├── data/
│   │   │   ├── models/consulta.dart
│   │   │   └── mock_data/consultas_mock.dart
│   │   └── presentation/screens/
│   │       ├── consultas_screen.dart
│   │       └── consulta_detail_screen.dart
│   ├── pagos/
│   │   ├── data/
│   │   │   ├── models/pago.dart
│   │   │   ├── mock_data/pagos_mock.dart
│   │   │   └── services/payment_service.dart  # Redsys placeholder (TODO PHASE 2)
│   │   └── presentation/screens/
│   │       ├── pagos_screen.dart
│   │       └── pago_detail_screen.dart
│   ├── notificaciones/
│   │   ├── data/
│   │   │   ├── models/notificacion.dart
│   │   │   ├── mock_data/notificaciones_mock.dart
│   │   │   └── services/notification_service.dart  # Push notifications placeholder (TODO PHASE 2)
│   │   └── presentation/screens/
│   │       └── notificaciones_screen.dart
│   ├── ajustes/
│   │   └── presentation/screens/
│   │       └── ajustes_screen.dart
│   └── descargas/
│       └── presentation/screens/
│           ├── descargas_screen.dart
│           └── historial_screen.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.2.0 <4.0.0)
- Dart SDK (>=3.2.0 <4.0.0)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)
- **Supabase Project** with TOTP MFA enabled
- **User created manually** in Supabase Dashboard

### Installation

1. **Clone the repository** (or use the existing directory)
   ```bash
   cd c:\development\jacpae_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a user in Supabase Dashboard → Authentication → Users
   - Enable TOTP in Authentication → Multi-Factor Authentication
   - Get your project URL and anon key from Settings → API

4. **Configure environment variables** (ver [docs/setup.md](docs/setup.md) para más opciones)

   **Opción A - Archivo .env (Recomendado):**
   ```bash
   # Copiar archivo de ejemplo
   cp .env.example .env

   # Editar .env con tus credenciales reales
   # Luego ejecutar:
   run_dev.bat        # Windows
   ./run_dev.sh       # macOS/Linux
   ```

   **Opción B - VS Code:**
   - Editar `.vscode/launch.json` con tus credenciales
   - Presionar F5 para ejecutar

   **Opción C - Comando directo:**
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

### Testing the App

**Login Screen:**
- Email: User email created in Supabase
- Password: User password from Supabase
- **Note:** Real authentication - invalid credentials will fail

**MFA Setup (First Login):**
1. After successful login, you'll see MFA Enrollment screen
2. Scan QR code with authenticator app (Google Authenticator, Authy, etc.)
3. Enter 6-digit code from your authenticator app
4. You'll be redirected to home screen

**MFA Verification (Subsequent Logins):**
1. After login, you'll see MFA Verification screen
2. Open your authenticator app
3. Enter current 6-digit code
4. You'll be redirected to home screen

**Available Features:**
- ✅ Home/Dashboard - Navigation menu
- ✅ Consultas - View mock queries with status
- ✅ Pagos - View mock payments
- ✅ Notificaciones - View mock notifications
- ✅ Ajustes - Settings screen
- ✅ Descargas - Mock document downloads
- ✅ Historial - Mock activity history

---

## 🔐 Authentication & MFA

### Supabase Authentication Flow

1. **Login** → User enters email/password
2. **MFA Check** → App checks if user has TOTP factor
   - **First time**: Redirect to MFA Enrollment
   - **Has TOTP**: Redirect to MFA Verification
3. **MFA Enrollment** (first time only)
   - Show QR code and secret
   - User scans with authenticator app
   - User enters 6-digit code
   - Factor is saved to Supabase
4. **MFA Verification** (every login)
   - User opens authenticator app
   - User enters current 6-digit code
   - Session elevated to AAL2
5. **Home Screen** → User has full access

### Assurance Levels (AAL)

- **AAL1**: User authenticated with email/password only
  - ❌ **No access to app**
  - Must complete MFA verification
  - Session expires in 15 minutes (Enhanced MFA Security)

- **AAL2**: User authenticated with email/password + TOTP
  - ✅ **Full access to app**
  - Can navigate all screens
  - Session persists per Supabase config

### Navigation Guards

The router enforces MFA before allowing access:

| User State | Requested Route | Action |
|-----------|----------------|---------|
| Not logged in | Any | → `/` (Login) |
| AAL1 (no MFA) | Private routes | → `/mfa/verify` |
| AAL2 + lock activo | Private routes | → `/lock` (biometría) |
| AAL2 (with MFA) | Auth pages | → `/home` |
| AAL2 (with MFA) | Private routes | ✅ Allowed |

### Creating Users

**Users must be created manually in Supabase Dashboard:**

1. Go to Supabase Dashboard → Authentication → Users
2. Click "Add user" → "Create new user"
3. Enter email and password
4. Check "Auto Confirm User" (to skip email confirmation)
5. Click "Create user"

**No signup from the app** - this is intentional for security.

### Supported Authenticator Apps

- Google Authenticator (iOS, Android)
- Authy (iOS, Android, Desktop)
- Microsoft Authenticator (iOS, Android)
- 1Password (Premium)
- Bitwarden (Open Source)

### Security Features

✅ **Implemented:**
- Email/password authentication
- Mandatory TOTP MFA
- AAL2 enforcement (cannot skip MFA)
- Enhanced MFA Security (AAL1 expires in 15 min)
- PKCE flow
- Only anon key in client (no service_role exposure)
- Navigation guards
- Bloqueo biométrico local (10 min timeout)

⚠️ **Not Implemented (Future):**
- Password reset
- Account recovery
- Rate limiting

### 🔒 Bloqueo de aplicación (biometría)

La app incluye un bloqueo local por biometría como refuerzo de seguridad adicional al MFA.

**Comportamiento:**
- Si la app pasa **10 minutos o más en segundo plano**, al volver se muestra una pantalla de bloqueo
- El usuario debe autenticarse con huella dactilar, reconocimiento facial o credencial del dispositivo (según lo que tenga configurado)
- Tras desbloquear, se retoma la sesión normalmente sin repetir login ni MFA

**Fallback (sin biometría):**
- Si el dispositivo **no soporta biometría** o el usuario **no tiene biometría configurada**, la app **no aplica el bloqueo** y permite el acceso directo
- Este comportamiento es automático y no requiere configuración

**Notas de seguridad:**
- No sustituye al MFA (TOTP); es un refuerzo local complementario
- No se almacenan credenciales en el dispositivo
- El bloqueo solo aplica cuando ya existe una sesión Supabase válida (AAL2)

**Archivos clave:**
- `lib/core/security/biometric_service.dart` — servicio de biometría
- `lib/core/security/app_lock_controller.dart` — controller de timeout y lifecycle
- `lib/core/security/lock_screen.dart` — pantalla de desbloqueo

**QA / Cómo probar:**
1. Inicia sesión normalmente (login + MFA)
2. Deja la app en segundo plano durante **10 minutos o más**
3. Vuelve a la app → debe aparecer la pantalla de bloqueo
4. Pulsa "Desbloquear" → el dispositivo pide huella/cara
5. Tras autenticarse, vuelves al dashboard
6. Verificar: si vuelves antes de 10 minutos, **no** pide desbloqueo

📚 **For detailed auth documentation**, see [docs/auth.md](docs/auth.md)

---

## 📱 Screens

### 1. Login Screen
- Material 3 design
- Real email/password authentication
- Error handling for invalid credentials
- Redirects to MFA enrollment or verification

### 2. MFA Enrollment Screen (First Time)
- QR code display (placeholder - shows icon)
- Secret code with copy button
- 6-digit code input
- Verification and factor enrollment

### 3. MFA Verification Screen (Every Login)
- 6-digit code input
- Challenge and verify flow
- Error handling for invalid codes
- Session elevation to AAL2

### 4. Home/Dashboard
- Grid menu with 6 options
- Badge counters on items
- Phase 1 notice banner

### 3. Consultas (Queries)
- List of queries with status (pendiente/en_proceso/resuelta)
- Detail view with responses
- Floating action button (non-functional in Phase 1)

### 4. Pagos (Payments)
- Payment list with amounts and status
- Detail view
- Payment button (shows Phase 1 notice)

### 5. Notificaciones
- List of notifications by type
- Read/unread indicators
- Time formatting (relative times)

### 6. Ajustes (Settings)
- Account settings
- Notification preferences
- App information
- **Real logout functionality** (clears session, returns to login)

### 7. Descargas (Downloads)
- Mock PDF document list
- Download button (shows Phase 1 notice)

### 8. Historial (History)
- Activity timeline with icons
- Date/time formatting

---

## 🎨 Design System

### Material 3 Theme
- Primary Color: `#1976D2` (Blue)
- Secondary Color: `#26A69A` (Teal)
- Error Color: `#D32F2F` (Red)
- Success Color: `#4CAF50` (Green)
- Warning Color: `#FFA726` (Orange)

### Typography
- Display Large: 32px, Bold
- Display Medium: 28px, Bold
- Display Small: 24px, Bold
- Headline Medium: 20px, Semi-Bold
- Title Large: 18px, Semi-Bold
- Body Large: 16px
- Body Medium: 14px

### Spacing Scale
- XS: 4px
- S: 8px
- M: 16px
- L: 24px
- XL: 32px

### Border Radius
- S: 4px
- M: 8px
- L: 12px
- XL: 16px

---

## 🔌 Services

### AuthService (✅ Implemented)
- `signInWithPassword()` - Real Supabase authentication
- `signOut()` - Clears session
- `isAuthenticated` - Checks current session
- `isAAL2` - Checks if MFA verified
- `hasTOTPFactor()` - Checks if user has TOTP enrolled
- `enrollTOTP()` - Enrolls new TOTP factor
- `challengeAndVerifyMFA()` - Verifies TOTP code
- `getMFAFactors()` - Gets user's MFA factors

### PaymentService (Redsys)
- `processPayment()` - NOT IMPLEMENTED
- `getPaymentStatus()` - NOT IMPLEMENTED
- `cancelPayment()` - NOT IMPLEMENTED

### NotificationService
- `initialize()` - NOT IMPLEMENTED
- `requestPermissions()` - NOT IMPLEMENTED
- `subscribeToTopic()` - NOT IMPLEMENTED

### ApiService (MariaDB)
- `get()` - NOT IMPLEMENTED
- `post()` - NOT IMPLEMENTED
- `put()` - NOT IMPLEMENTED
- `delete()` - NOT IMPLEMENTED

### SupabaseService
- `initialize()` - NOT IMPLEMENTED
- `query()` - NOT IMPLEMENTED
- `insert()` - NOT IMPLEMENTED
- `update()` - NOT IMPLEMENTED
- `delete()` - NOT IMPLEMENTED

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  go_router: ^14.0.0
  flutter_riverpod: ^2.5.1
  supabase_flutter: ^2.5.0  # NEW: Auth + MFA

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

**All dependencies use stable versions** - no beta/dev packages.

---

## ✅ Validation Checklist

- [x] Project compiles without errors
- [x] All screens are navigable
- [x] Mock data displays correctly
- [x] Material 3 theme applied consistently
- [x] No real backend calls
- [x] All services are placeholders
- [x] Phase 1 notices displayed
- [x] Logout returns to login
- [x] Form validations work (UI only)
- [x] Compatible package versions

---

## 🚦 Next Steps (Future Phases)

### PHASE 2: Backend Integration ✅ (Auth Complete)
- [x] Implement Supabase authentication
- [x] Add MFA TOTP enforcement
- [x] Add session management
- [x] Implement auth state management
- [ ] Connect to MariaDB via API service
- [ ] Implement real data models
- [ ] Implement push notifications setup

### PHASE 3: Business Logic
- [ ] Integrate Redsys payment gateway
- [ ] Implement document downloads
- [ ] Add real-time updates
- [ ] Implement data caching
- [ ] Add offline support

### PHASE 4: Production Ready
- [ ] Security hardening
- [ ] Performance optimization
- [ ] Error handling
- [ ] Analytics integration
- [ ] App store deployment

---

## 🔍 Finding TODO Comments

Search for `TODO PHASE 2` in the codebase to find all placeholder implementations:

```bash
grep -r "TODO PHASE 2" lib/
```

**Total TODO markers:** ~30+ across services and features

---

## 🛠️ Development Commands

### Ejecutar la aplicación

**Método 1 - Scripts helper (Recomendado):**
```bash
# Windows
run_dev.bat

# macOS/Linux
./run_dev.sh
```

**Método 2 - VS Code:**
- Presionar `F5` y seleccionar "Flutter (Dev - Supabase)"

**Método 3 - Comando directo:**
```bash
# Instalar dependencias
flutter pub get

# Ejecutar con credenciales
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key

# Con dispositivo específico
flutter run -d <device-id> \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key
```

### Builds de producción

```bash
# Android APK
flutter build apk \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# iOS
flutter build ios \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### Desarrollo

```bash
# Ejecutar tests
flutter test

# Analizar código
flutter analyze

# Formatear código
dart format lib/
```

**⚠️ Importante**:
- Nunca subas credenciales de Supabase al repositorio
- El archivo `.env` está en `.gitignore`
- Ver [docs/setup.md](docs/setup.md) para más opciones de configuración

---

## 📝 Notes

1. **Login:** Real authentication - only valid Supabase users can log in
2. **MFA Required:** Cannot access app without completing TOTP verification
3. **Navigation:** Protected by auth guards - must be AAL2 to access
4. **Data:** Feature data is still mocked (Consultas, Pagos, etc.)
5. **Services:** Auth is real, other services (payments, downloads) are still placeholders
6. **Payments:** Payment button still shows Phase 1 notice
7. **Downloads:** Download action still shows Phase 1 notice
8. **Logout:** Real logout clears Supabase session and returns to login

---

## ⚠️ Important Reminders

**Authentication is production-ready, but other features are still mocked.**

✅ **Production-ready:**
- ✅ Authentication (Supabase)
- ✅ MFA TOTP enforcement
- ✅ Session management
- ✅ Navigation guards
- ✅ Logout functionality

⚠️ **Still in development (mocked):**
- ❌ Consultas (queries) data
- ❌ Pagos (payments) processing
- ❌ Notificaciones (notifications)
- ❌ Document downloads
- ❌ Database persistence

---

## 📄 License

Internal project - PHASE 1 (UI Scaffolding Only)

---

## 👥 Contact

For questions about future phase implementation, refer to the TODO comments in the codebase.

**Ready for PHASE 2 implementation when approved.**
