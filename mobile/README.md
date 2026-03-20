# TaskFlow Mobile — Track B (Flutter)

A Flutter mobile app for the TaskFlow Task Management System. Targets Android (APK) and iOS.

---

## Architecture

Clean Architecture with BLoC state management:

```
lib/
├── main.dart                         # Entry point
├── app.dart                          # Root widget, MultiBlocProvider
├── core/
│   ├── constants/app_constants.dart  # Base URL, storage keys
│   ├── di/injection_container.dart   # GetIt dependency injection
│   ├── errors/failures.dart          # Failure types
│   ├── errors/error_handler.dart     # Dio → Failure mapping
│   ├── network/api_client.dart       # Dio + auto token-refresh interceptor
│   ├── router/app_router.dart        # Named route navigation
│   ├── storage/secure_storage_service.dart
│   └── theme/app_theme.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/auth_remote_datasource.dart
│   │   │   ├── models/auth_model.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart    # Abstract
│   │   │   └── usecases/auth_usecases.dart
│   │   └── presentation/
│   │       ├── bloc/auth_bloc.dart + auth_event.dart + auth_state.dart
│   │       ├── pages/splash_page.dart
│   │       ├── pages/login_page.dart
│   │       ├── pages/register_page.dart
│   │       └── widgets/app_text_field.dart
│   │
│   └── tasks/
│       ├── data/
│       │   ├── datasources/task_remote_datasource.dart
│       │   ├── models/task_model.dart
│       │   └── repositories/task_repository_impl.dart
│       ├── domain/
│       │   ├── entities/task_entity.dart
│       │   ├── repositories/task_repository.dart     # Abstract
│       │   └── usecases/task_usecases.dart
│       └── presentation/
│           ├── bloc/task_bloc.dart + task_event.dart + task_state.dart
│           ├── pages/task_dashboard_page.dart
│           ├── pages/task_form_page.dart
│           └── widgets/task_card.dart + filter_bar.dart
```

---

## Prerequisites

- Flutter SDK ≥ 3.2.0 ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or VS Code with Flutter extension
- Android emulator or physical Android device
- Backend running on `http://localhost:4000`

---

## Setup

```bash
cd mobile

# Install dependencies
flutter pub get

# Verify setup
flutter doctor

# Run on emulator/device
flutter run

# Build release APK
flutter build apk --release
# APK output: build/app/outputs/flutter-apk/app-release.apk
```

---

## API Base URL

The app connects to the backend via:
```dart
// lib/core/constants/app_constants.dart
static const String baseUrl = 'http://10.0.2.2:4000';
```

- `10.0.2.2` maps to `localhost` on the **Android emulator**
- For a **physical device**, replace with your machine's local IP, e.g. `http://192.168.1.10:4000`
- For **production**, replace with your deployed API URL

---

## Key Features

| Feature | Implementation |
|---|---|
| Secure token storage | `flutter_secure_storage` with Android encrypted prefs |
| Auto token refresh | Dio interceptor retries on 401 with fresh access token |
| State management | BLoC (flutter_bloc ^8) |
| DI | GetIt service locator |
| Pagination | Infinite scroll with `ScrollController` |
| Pull-to-refresh | `RefreshIndicator` |
| Error handling | Friendly Snackbars + Dialogs for all error types |
| Navigation | Named routes with custom page transitions |

---

## Building APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by ABI (smaller file size)
flutter build apk --split-per-abi
```

APKs are output to: `build/app/outputs/flutter-apk/`
