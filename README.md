# JacPae App - PHASE 1: UI & Scaffolding

> **⚠️ IMPORTANT: This is PHASE 1 - UI + Structure ONLY**
>
> This phase provides complete visual scaffolding with mock data. No real backend integration is implemented.

## 🎯 Project Overview

Flutter mobile application (Android/iOS) for company-client communication built with Material 3 design.

**Current Phase:** PHASE 1 - UI + Scaffolding
**Version:** 1.0.0+1
**Status:** ✅ Ready for UI/UX validation

---

## 📋 What's Included in PHASE 1

### ✅ Implemented
- Complete UI for all screens with Material 3
- Feature-based modular architecture
- Navigation system with go_router
- Mock data for all features
- Placeholder services (ready for Phase 2)
- Reusable widget components
- Global theming system

### ❌ NOT Implemented (Future Phases)
- Real authentication (Supabase)
- Backend API calls (MariaDB)
- Payment gateway integration (Redsys)
- Push notifications (Firebase/OneSignal)
- Session management
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

### Installation

1. **Clone the repository** (or use the existing directory)
   ```bash
   cd c:\development\jacpae_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Testing the App

**Login Screen:**
- Email: Any email format (e.g., `test@example.com`)
- Password: Any password (min 6 characters)
- **Note:** All credentials are accepted in Phase 1

**Available Features:**
- ✅ Home/Dashboard - Navigation menu
- ✅ Consultas - View mock queries with status
- ✅ Pagos - View mock payments
- ✅ Notificaciones - View mock notifications
- ✅ Ajustes - Settings screen
- ✅ Descargas - Mock document downloads
- ✅ Historial - Mock activity history

---

## 📱 Screens

### 1. Login Screen
- Material 3 design
- Email/password validation (UI only)
- Phase 1 notice

### 2. Home/Dashboard
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
- Logout functionality

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

## 🔌 Placeholder Services

All services throw `UnimplementedError` with `// TODO PHASE 2` comments:

### AuthService
- `login()` - Always returns true
- `logout()` - No-op
- `isAuthenticated()` - Always returns false
- Other methods throw UnimplementedError

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

### PHASE 2: Backend Integration
- [ ] Implement Supabase authentication
- [ ] Connect to MariaDB via API service
- [ ] Implement real data models
- [ ] Add session management
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

```bash
# Install dependencies
flutter pub get

# Run app (development)
flutter run

# Run with specific device
flutter run -d <device-id>

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/
```

---

## 📝 Notes

1. **Login:** Any credentials work - there's no validation in Phase 1
2. **Navigation:** All screens are accessible from the dashboard
3. **Data:** All data is mocked - nothing is persisted
4. **Services:** All backend calls will throw `UnimplementedError`
5. **Payments:** Payment button shows Phase 1 notice
6. **Downloads:** Download action shows Phase 1 notice
7. **Forms:** Validation is UI-only, no data is sent anywhere

---

## ⚠️ Important Reminders

**This is NOT a production application.**

✅ **Use this phase to:**
- Validate UI/UX design
- Test navigation flow
- Verify screen layouts
- Review color scheme and typography
- Gather user feedback on interface

❌ **Do NOT use this phase for:**
- Real user authentication
- Actual payment processing
- Production deployment
- Real data handling
- Security testing

---

## 📄 License

Internal project - PHASE 1 (UI Scaffolding Only)

---

## 👥 Contact

For questions about future phase implementation, refer to the TODO comments in the codebase.

**Ready for PHASE 2 implementation when approved.**
