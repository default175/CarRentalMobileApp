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
        brand=document["brand"],
        model=document["model"],
        year=document["year"],
        type=document["type"],
        category=document.get("category"),
        price_per_hour=document["price_per_hour"],
        status=document["status"],
        battery_level=document["battery_level"],
        range_km=document["range_km"],
        seats=document.get("seats"),
        transmission=document.get("transmission"),
        color=document.get("color"),
        description=document.get("description"),
        features=document.get("features", []),
        image_url=document.get("image_url"),
        has_gps_signal=document.get("has_gps_signal", True),
        location=document["location"],
    )


def map_booking(document: dict) -> BookingSchema:
    return BookingSchema(
        id=document["_id"],
        user_id=document["user_id"],
        user_name=document.get("user_name"),
        car_id=document["car_id"],
        car_name=document["car_name"],
        start_time=document["start_time"],
        end_time=document["end_time"],
        status=document["status"],
        total_price=document["total_price"],
        distance_km=document["distance_km"],
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
        name=document["name"],
        email=document["email"],
        phone=document["phone"],
        role=document["role"],
        license_number=document.get("license_number"),
        photo_url=document.get("photo_url"),
        created_at=document.get("created_at"),
        blocked=document["blocked"],
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
