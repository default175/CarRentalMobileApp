from __future__ import annotations

from .schemas import (
    AdminOverviewSchema,
    BookingSchema,
    CarSchema,
    NotificationSchema,
    TrackingSchema,
    UserSchema,
)


def map_car(document: dict) -> CarSchema:
    return CarSchema(
        id=document["_id"],
        brand=document.get("brand", "Unknown"),
        model=document.get("model", "Car"),
        year=document.get("year", 2024),
        type=document.get("type", "Sedan"),
        category=document.get("category"),
        price_per_hour=document.get("price_per_hour", 0),
        status=document.get("status", "available"),
        battery_level=document.get("battery_level", 0),
        range_km=document.get("range_km", 0),
        seats=document.get("seats"),
        transmission=document.get("transmission"),
        color=document.get("color"),
        description=document.get("description"),
        features=document.get("features", []),
        fuel_type=document.get("fuel_type", "Petrol"),
        gas_level=document.get("gas_level"),
        engine_volume=document.get("engine_volume"),
        mileage_km=document.get("mileage_km", 0),
        drive=document.get("drive", "front"),
        registered=document.get("registered", True),
        image_url=document.get("image_url"),
        has_gps_signal=document.get("has_gps_signal", True),
        location=document.get("location", {"lat": 43.2389, "lng": 76.8897}),
    )


def map_booking(document: dict) -> BookingSchema:
    return BookingSchema(
        id=document["_id"],
        user_id=document.get("user_id", "user-unknown"),
        user_name=document.get("user_name"),
        car_id=document.get("car_id", "car-unknown"),
        car_name=document.get("car_name", "Unknown car"),
        start_time=document["start_time"],
        end_time=document["end_time"],
        status=document.get("status", "created"),
        total_price=document.get("total_price", 0),
        distance_km=document.get("distance_km", 0),
        route_summary=document.get("route_summary"),
    )


def map_notification(document: dict) -> NotificationSchema:
    return NotificationSchema(
        id=document["_id"],
        title=document["title"],
        message=document["message"],
        type=document["type"],
        created_at=document["created_at"],
    )


def map_user(document: dict) -> UserSchema:
    return UserSchema(
        id=document["_id"],
        name=document.get("name", "Unknown user"),
        email=document.get("email", ""),
        phone=document.get("phone", ""),
        role=document.get("role", "user"),
        license_number=document.get("license_number"),
        photo_url=document.get("photo_url"),
        created_at=document.get("created_at"),
        blocked=document.get("blocked", False),
    )


def map_tracking(document: dict) -> TrackingSchema:
    return TrackingSchema(
        car_id=document["car_id"],
        lat=document["lat"],
        lng=document["lng"],
        speed_kph=document["speed_kph"],
        is_inside_geofence=document["is_inside_geofence"],
        geofence_name=document["geofence_name"],
        distance_km=document["distance_km"],
        updated_at=document["updated_at"],
        route=document["route"],
    )


def map_admin_overview(users: list[dict], cars: list[dict], bookings: list[dict]) -> AdminOverviewSchema:
    mapped_bookings = [map_booking(item) for item in bookings]
    return AdminOverviewSchema(
        users=[map_user(item) for item in users],
        cars=[map_car(item) for item in cars],
        bookings=mapped_bookings,
        active_trips=sum(1 for item in mapped_bookings if item.status == "active"),
    )
