# Car Rental App

Flutter client for a diploma project on car rental with GPS tracking, geofence alerts, bookings and an admin role.

## What is implemented

- feature-based architecture aligned with the reference project
- demo mode fallback when external services are not configured
- Firebase-ready bootstrap for auth, realtime database and messaging
- Mapbox-ready tracking screen with automatic fallback to text mode
- MongoDB backend blueprint and environment contract

## Structure

```text
lib/
  app/
  bootstrap/
  core/
    config/
    di/
    network/
    routing/
    services/
    theme/
  shared/
    demo/
    models/
    widgets/
  features/
    auth/
    cars/
    bookings/
    tracking/
    notifications/
    admin/
    home/
docs/
  mongodb_backend_blueprint.md
scripts/
```

## Environment

Create a local `.env` file in the project root based on `.env.example`.

Supported keys:
- `API_BASE_URL`
- `ENABLE_BACKEND_API`
- `MAPBOX_ACCESS_TOKEN`
- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_DATABASE_URL`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_AUTH_DOMAIN`
- `MONGODB_URI`
- `MONGODB_DB`

`run_dev.ps1` now reads `.env` and forwards valid values into Flutter as `--dart-define`.

## Run

1. Create `.env` from `.env.example`
2. Run `.\scripts\bootstrap.ps1`
3. Start backend with `powershell -ExecutionPolicy Bypass -File .\scripts\run_backend.ps1`
4. Run frontend with `powershell -ExecutionPolicy Bypass -File .\scripts\run_dev.ps1 -DeviceId edge`

Validation:
- `.\scripts\analyze.ps1`
- `.\scripts\test.ps1`
- `python -m compileall backend\app`

## Runtime behavior

- If Firebase config is missing, the app uses demo repositories.
- If Mapbox token is missing, tracking falls back to the text view.
- MongoDB is not used from Flutter directly. It belongs to backend services.
- For local development, use MongoDB Community Server plus MongoDB Compass as the GUI.

## MongoDB

Backend collection layout and integration contract are documented in:
- [mongodb_backend_blueprint.md](C:/Users/M/Documents/CarRental/App/docs/mongodb_backend_blueprint.md)

Backend implementation entry point:
- [main.py](C:/Users/M/Documents/CarRental/App/backend/app/main.py)
