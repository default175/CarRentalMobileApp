# Architecture

## Mobile Layers

- `core`: env, config, routing, theme, DI
- `shared`: reusable models and widgets
- `features`: isolated business modules

## Feature Modules

- `auth`: вход, роли, сессия
- `cars`: каталог и доступность автомобилей
- `bookings`: бронирование, история и статусы аренды
- `tracking`: GPS, geofencing, route history
- `notifications`: системные и бизнес-уведомления
- `admin`: автопарк, пользователи, аналитика

## Integration Target

- `Flutter client` -> `REST API`
- `REST API` -> `MongoDB`
- `Firebase Auth` -> login / refresh token / role claims
- `Firebase Messaging` -> push notifications
- `Firebase Realtime stream or WebSocket gateway` -> live GPS updates
- `Mapbox` -> maps, routes, geofence rendering

## Suggested Backend Modules

- `auth`
- `users`
- `cars`
- `rentals`
- `tracking`
- `notifications`
- `admin`

## Priority Roadmap

1. Подключить Flutter SDK и сгенерировать платформенные папки `flutter create .`
2. Подменить fake repositories на HTTP/Firebase adapters
3. Добавить DTO, mappers и error handling
4. Подключить Mapbox widget и live location overlay
5. Реализовать backend контракты и авторизацию по JWT/Firebase
