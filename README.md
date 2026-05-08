# Car Rental GPS

A Flutter car rental application with local demo mode, MongoDB backend API, Firebase, MapBox, GPS tracking, favorites, bookings, wallet, notifications, and an admin panel.

The project is written with Flutter. Files in `lib/*.dart` are the normal structure of a Flutter application: Flutter provides the UI and platform layer, while Dart is the programming language used to write the app logic.

## Features

- User registration and sign in.
- Local demo mode without a backend, useful for testing the APK on any device.
- MongoDB backend API built with FastAPI.
- Firebase Auth, Realtime Database, and Messaging support when keys are configured.
- MapBox map and fallback map when the token is not configured.
- Car catalog with filters by price, year, fuel type, category, features, and availability.
- Car detail pages, reviews, review-based rating, and favorites.
- Bookings are created only after order confirmation.
- Wallet with payment methods and saved cards.
- Push/local notifications that can be disabled in settings.
- Admin panel for users, cars, and bookings.
- Admin GPS view: shows rented cars instead of the full catalog.

## Quick Start

1. Install dependencies:

```powershell
flutter pub get
```

2. Run the app in demo mode:

```powershell
flutter run --dart-define=ENABLE_BACKEND_API=false
```

3. Build a release APK:

```powershell
flutter build apk --release --dart-define=ENABLE_BACKEND_API=false
```

The generated APK will be available here:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Demo Accounts

```text
Regular user:
user@demo.app / demo123

Administrator:
admin@demo.app / demo123
```

In demo mode, you can register new users. A newly registered user starts with no bookings. Registered demo users are visible to the administrator in the admin panel.

The admin panel is available to the administrator through:

```text
Profile -> Admin
```

## Project Structure

```text
lib/
  app/                    Flutter application shell
  core/
    config/               runtime config and dart-define parameters
    di/                   Riverpod providers
    location/             geolocation request and access control
    network/              API client and backend API settings
    routing/              GoRouter routes
    services/             Firebase, MapBox, local storage, notifications
    theme/                light and dark themes
  features/
    admin/                admin panel
    auth/                 sign in, registration, welcome screen
    bookings/             bookings
    cars/                 car catalog and car details
    extras/               extra screens: wallet, settings, reviews, etc.
    home/                 home screen
    notifications/        notifications
    profile/              profile
    tracking/             GPS and map
  shared/
    demo/                 local demo data
    models/               data models

backend/
  app/                    FastAPI backend for MongoDB

scripts/
  build_release_apk.ps1   builds the release APK
  run_backend.ps1         starts the backend
  run_dev.ps1             starts Flutter
  analyze.ps1             runs flutter analyze
  test.ps1                runs flutter test
```

## Requirements

- Flutter SDK `3.19+`.
- Dart SDK `3.3+`.
- Android SDK or Android Studio.
- Python `3.10+`.
- MongoDB Community Server if backend mode is needed.
- PowerShell on Windows.

Check Flutter:

```powershell
flutter doctor
```

## `.env` Configuration

The project uses a root `.env` file. An example is available in `.env.example`.

```env
API_BASE_URL=http://127.0.0.1:8080
ENABLE_BACKEND_API=false
MAPBOX_ACCESS_TOKEN=replace_me
FIREBASE_API_KEY=replace_me
FIREBASE_APP_ID=replace_me
FIREBASE_MESSAGING_SENDER_ID=replace_me
FIREBASE_PROJECT_ID=replace_me
FIREBASE_DATABASE_URL=https://replace-me-default-rtdb.firebaseio.com
FIREBASE_STORAGE_BUCKET=replace-me.firebasestorage.app
FIREBASE_AUTH_DOMAIN=replace-me.firebaseapp.com
MONGODB_URI=mongodb://127.0.0.1:27017
MONGODB_DB=car_rental
```

For an APK that should work on any device without requiring a backend, use:

```text
ENABLE_BACKEND_API=false
```

After installing the APK, the backend can be enabled inside the app:

```text
Profile -> Settings -> Backend API
```

There you can set the real API URL and enable `Use MongoDB backend API`.

## Local Demo Mode

Demo mode is used when the backend is disabled or unavailable. Data is stored locally on the device through `SharedPreferences`.

What works in demo mode:

- registration and sign in;
- car catalog;
- favorites;
- bookings;
- wallet and cards;
- notifications;
- app theme;
- admin panel with demo data and newly registered users.

To fully reset demo data, clear the app data on the device:

```text
Android Settings -> Apps -> Car Rental -> Storage -> Clear data
```

## MongoDB Backend

The backend is located in the `backend/` directory.

Install dependencies:

```powershell
cd backend
python -m pip install -r requirements.txt
```

Run for the current computer only:

```powershell
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8080
```

Run for a phone on the same Wi-Fi network:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_backend.ps1 -HostAddress 0.0.0.0 -Port 8080
```

Check the backend:

```powershell
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/api/cars
```

On startup, the backend adds seed data to MongoDB if it is missing. Cars, users, and bookings from MongoDB become visible in the app after enabling the backend API.

## API URL For Emulator And Real Phone

`http://10.0.2.2:8080` works only inside Android Emulator. It does not work on a real phone.

For a real phone:

1. Start the backend on `0.0.0.0`.
2. Find the computer IPv4 address:

```powershell
ipconfig
```

3. Find the Wi-Fi address, for example:

```text
192.168.1.25
```

4. Check it from the phone browser:

```text
http://192.168.1.25:8080/health
```

5. In the app, open:

```text
Profile -> Settings -> Backend API
```

6. Set:

```text
http://192.168.1.25:8080
```

7. Enable `Use MongoDB backend API` and save the settings.

If the app must work outside your Wi-Fi network, deploy the backend to a VPS or hosting provider and use a public domain, for example:

```text
https://api.your-domain.kz
```

## Firebase

Firebase is used for auth, realtime database, and push messaging when Firebase keys are passed through `.env` or `--dart-define`.

If Firebase is not configured, the application continues to work in demo mode.

For Android, you usually need:

- Firebase project.
- Android app in Firebase Console.
- `google-services.json` in `android/app/`.
- Firebase values in `.env`.

Push notifications can be disabled inside the app:

```text
Profile -> Settings -> Notifications
```

## MapBox

MapBox is used for the map and GPS tracking when `MAPBOX_ACCESS_TOKEN` is provided.

If the token is missing or the map is unavailable, the app shows a fallback map so the interface does not break.

## Geolocation

The app requests geolocation access on startup. If the user does not grant permission, the app blocks the main functionality because rental and GPS logic depend on the current city.

The home screen shows the user's city. In demo mode, cars on the map are placed at different points around the user.

## APK Build

Debug APK:

```powershell
flutter build apk --debug
```

Release APK without required backend:

```powershell
flutter build apk --release --dart-define=ENABLE_BACKEND_API=false
```

Release APK through the script:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_apk.ps1
```

Release APK with backend enabled by default:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_apk.ps1 -BackendEnabled
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Running In Browser

Flutter web can be used for quick UI checks:

```powershell
flutter run -d chrome --dart-define=ENABLE_BACKEND_API=false
```

With backend:

```powershell
flutter run -d chrome --dart-define=ENABLE_BACKEND_API=true --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

If the admin panel or API does not open in the browser, first check:

```text
http://127.0.0.1:8080/health
```

## Checks Before Build

Analyzer:

```powershell
flutter analyze
```

Tests:

```powershell
flutter test
```

Backend syntax:

```powershell
cd backend
python -m compileall app
```

## Troubleshooting

### Phone Cannot Reach Backend

- The phone and PC must be on the same network.
- The backend must be started on `0.0.0.0`, not only on `127.0.0.1`.
- Windows Firewall must allow incoming connections on port `8080`.
- The app must use the computer IP address, not `127.0.0.1` and not `10.0.2.2`.

### Cars Are Not Loaded From MongoDB

- Check `http://server-ip:8080/api/cars` in the phone browser.
- Enable `Use MongoDB backend API` in app settings.
- Check `MONGODB_URI` and `MONGODB_DB`.
- Restart the backend after changing `.env`.

### Map Is Black Or Not Loading

- Check `MAPBOX_ACCESS_TOKEN`.
- Check internet access on the device.
- Check that the MapBox token is allowed for Android.

### Push Notifications Do Not Appear

- Check Android notification permission.
- Check Firebase config.
- Check that notifications are enabled in app settings.

### Theme Is Not Saved After Switching

The theme is stored locally. If it is not saved, check that app data is not being cleared by the system or emulator between launches.

## Useful Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=ENABLE_BACKEND_API=false
flutter build apk --release --dart-define=ENABLE_BACKEND_API=false
```

