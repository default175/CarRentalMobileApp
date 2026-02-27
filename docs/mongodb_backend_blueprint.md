# MongoDB Backend Blueprint

MongoDB belongs in the backend layer, not in the Flutter client.

MongoDB Compass is only the GUI client. The actual local database should be
MongoDB Community Server running on your machine, and Compass connects to it.

## Recommended services

- `auth-service`
- `car-service`
- `rental-service`
- `notification-service`
- `tracking-service`

## Environment

```env
MONGODB_URI=mongodb://127.0.0.1:27017
MONGODB_DB=car_rental
```

## Local setup

1. Install MongoDB Community Server locally.
2. Start the MongoDB service on your machine.
3. Open MongoDB Compass.
4. Connect Compass to `mongodb://127.0.0.1:27017`.
5. Create the `car_rental` database and required collections.

## Collections

### `users`
- `_id`
- `name`
- `email`
- `phone`
- `role`
- `blocked`
- `created_at`

### `cars`
- `_id`
- `brand`
- `model`
- `year`
- `type`
- `price_per_hour`
- `status`
- `current_location`
- `range_km`

### `rentals`
- `_id`
- `user_id`
- `car_id`
- `start_time`
- `end_time`
- `status`
- `total_price`

### `trip_history`
- `_id`
- `rental_id`
- `route_data`
- `distance_km`
- `geofence_events`

### `notifications`
- `_id`
- `user_id`
- `type`
- `title`
- `message`
- `created_at`

## Integration contract with Flutter

Flutter should call backend APIs for:
- cars catalog
- bookings/rentals
- admin overview
- notification history

Firebase should be used for:
- auth
- live GPS stream
- push notifications
