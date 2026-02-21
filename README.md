Jacpae App

Secure B2B mobile application with mandatory MFA (AAL2), biometric App Lock and authenticated document delivery.

Flutter mobile application for professional company-client communication.
Implements Supabase authentication with enforced MFA, secure backend integration for notifications, and authenticated PDF offer downloads with local persistence.

🎯 Project Overview

Version: 1.0.0+1
Status: ✅ Production-ready authentication, security layer and backend integration for notifications & offers.

Built with:

Flutter (stable)

Riverpod (state management)

GoRouter (navigation + security guards)

Supabase (authentication + JWT sessions)

Custom REST API (notifications & offers)

🏗️ Project Structure
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   ├── network/           # ApiClient + ApiException
│   ├── router/            # GoRouter configuration + guards
│   ├── security/          # App Lock + biometric integration
│   ├── theme/
│   └── widgets/           # Shared UI components
│
└── features/
    ├── auth/              # Supabase authentication & MFA
    ├── home/              # Dashboard
    ├── invoices/          # API integration (invoices module)
    ├── notificaciones/    # Notifications (API + repository + Riverpod)
    ├── offers/            # Authenticated PDF streaming
    ├── descargas/         # Local document storage & management
    ├── consultas/         # Business module (fixtures pending API)
    ├── pagos/             # Business module (fixtures pending Redsys)
    ├── legal/             # Terms & privacy (Markdown)
    └── ajustes/
Architecture Pattern

Feature-based modular architecture

Repository pattern for API access

Riverpod StateNotifier for state management

GoRouter with security guards

Clear separation: data / repository / presentation

🔐 Authentication & Security
Supabase Authentication

Email/password authentication

Mandatory MFA TOTP (AAL2 required)

Session management with JWT

PKCE flow

No service_role keys in client

Assurance Levels

AAL1 → Email/password only → ❌ No access

AAL2 → Email/password + TOTP → ✅ Full access

Navigation guards enforce AAL2 before accessing private routes.

🔒 App Lock (Biometric)

After 10 minutes in background, the app requires biometric unlock:

Fingerprint / Face ID / Device credential

Uses WidgetsBindingObserver lifecycle tracking

Background timestamp persisted via SharedPreferences

Does not replace MFA — acts as local security reinforcement

Automatically disabled if device has no biometric capability

Files:

core/security/biometric_service.dart

core/security/app_lock_controller.dart

core/security/lock_screen.dart

🔔 Notifications (Backend Integrated)

Notifications are fully integrated with the backend API.

Endpoints

GET /notifications?limit=&offset=

PATCH /notifications/{id}/read

Features

JWT-authenticated requests (Supabase session token)

Pagination (limit/offset)

Optimistic UI updates

Mark single notification as read

Mark all as read (batch with partial rollback)

Proper error handling (Unauthorized, Forbidden, Network, etc.)

State handled via:

NotificationsRepository

NotificationsController (Riverpod)

Shared state between Home badge and Notifications screen

No mock data in active flow.

📄 Offers – Authenticated PDF Download

If a notification has type == "oferta":

Shows PDF icon

Calls backend via OffersRepository

Uses authenticated request (JWT)

Handles:

401 Unauthorized

404 OfferNotAvailableException

Downloads PDF

Stores locally

Redirects to Descargas screen

📦 Descargas (Local Persistence)

Downloaded PDFs:

Stored locally

Listed in Descargas screen

Openable from device

Deletable with optimistic update

Model:

DownloadedPdf

🚧 Business Modules Pending Full Backend

The following modules use temporary fixtures until API integration:

consultas

pagos (Redsys integration pending)

No mock_data directories remain in the project.

🚀 Getting Started
Prerequisites

Flutter SDK (stable)

Dart SDK

Android Studio / VS Code

Supabase project (with TOTP enabled)

Backend API running

Installation
cd C:\development\jacpae_app
flutter pub get
Environment Configuration

This project supports .env configuration.

Files present:

.env.example

run_dev.bat

run_dev.sh

docs/setup.md

Configure your .env with:

SUPABASE_URL=...
SUPABASE_ANON_KEY=...
API_BASE_URL=...

Run:

run_dev.bat

or

flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
🛠️ Development Commands
flutter analyze
flutter test
dart format lib/
flutter build apk

Current state:

flutter analyze → 0 issues

🛡️ Security Architecture

Supabase JWT-based authentication

MFA TOTP enforced (AAL2)

Biometric App Lock (10 min inactivity)

Secure API communication over HTTPS

No credential persistence

No service_role exposure

Optimistic updates with rollback safety

📄 License

Internal software developed for José Santiago Vargas S.A.

Private pilot deployment with selected professional clients.
Not open-source.

📌 Notes

Authentication and notification infrastructure are production-ready.

Offers PDF delivery is fully operational.

Payments (Redsys) integration pending.

Backend expansion for additional business modules planned.

👥 Contact

For technical questions, review repository structure and inline documentation.

