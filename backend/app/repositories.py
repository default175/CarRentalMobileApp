from __future__ import annotations

from datetime import datetime, timezone
from uuid import uuid4

from .db import mongo
from .mappers import map_admin_overview, map_booking, map_car, map_notification, map_tracking, map_user
from .seed import MEMORY_DB


def _collection(name: str):
    if mongo.available and mongo.db is not None:
        return mongo.db[name]
    return None


def _memory_documents(name: str) -> list[dict]:
    return MEMORY_DB.setdefault(name, [])


def _find_memory(name: str, document_id: str) -> dict | None:
    return next((item for item in _memory_documents(name) if item["_id"] == document_id), None)


def _upsert_memory(name: str, document: dict) -> dict:
    documents = _memory_documents(name)
    current = _find_memory(name, document["_id"])
    if current is None:
      documents.append(document)
    else:
      index = documents.index(current)
      documents[index] = document
    return document


def list_cars():
    collection = _collection("cars")
    documents = (
        list(collection.find().sort("_id", 1))
        if collection is not None
        else list(_memory_documents("cars"))
    )
    return [map_car(item) for item in documents]


def get_car(car_id: str) -> dict | None:
    collection = _collection("cars")
    if collection is not None:
        return collection.find_one({"_id": car_id})
    return _find_memory("cars", car_id)


def save_car(document: dict) -> dict:
    collection = _collection("cars")
    if collection is not None:
        collection.replace_one({"_id": document["_id"]}, document, upsert=True)
        return document
    return _upsert_memory("cars", document)


def delete_car(car_id: str) -> None:
    collection = _collection("cars")
    if collection is not None:
        collection.delete_one({"_id": car_id})
        collection_bookings = _collection("bookings")
        if collection_bookings is not None:
            collection_bookings.delete_many({"car_id": car_id})
        return
    MEMORY_DB["cars"] = [item for item in _memory_documents("cars") if item["_id"] != car_id]
    MEMORY_DB["bookings"] = [
        item for item in _memory_documents("bookings") if item["car_id"] != car_id
    ]


def list_users():
    collection = _collection("users")
    documents = (
        list(collection.find().sort("_id", 1))
        if collection is not None
        else list(_memory_documents("users"))
    )
    return [map_user(item) for item in documents]


def get_user_by_email(email: str) -> dict | None:
    collection = _collection("users")
    if collection is not None:
        return collection.find_one({"email": email.lower()})
    return next(
        (item for item in _memory_documents("users") if item["email"] == email.lower()),
        None,
    )


def get_user(user_id: str) -> dict | None:
    collection = _collection("users")
    if collection is not None:
        return collection.find_one({"_id": user_id})
    return _find_memory("users", user_id)


def save_user(document: dict) -> dict:
    collection = _collection("users")
    if collection is not None:
        collection.replace_one({"_id": document["_id"]}, document, upsert=True)
        return document
    return _upsert_memory("users", document)


def toggle_user_blocked(user_id: str) -> dict | None:
    user = get_user(user_id)
    if user is None:
        return None
    updated = {**user, "blocked": not user.get("blocked", False)}
    return save_user(updated)


def register_user(document: dict) -> dict:
    existing = get_user_by_email(document["email"])
    if existing is not None:
        raise ValueError("User with this email already exists.")
    return save_user(document)


def authenticate_user(email: str, password: str) -> dict | None:
    user = get_user_by_email(email)
    if user is None or user.get("password") != password:
        return None
    return user


def list_bookings():
    collection = _collection("bookings")
    documents = (
        list(collection.find().sort("start_time", -1))
        if collection is not None
        else list(_memory_documents("bookings"))
    )
    return [map_booking(item) for item in documents]


def create_booking(document: dict) -> dict:
    collection = _collection("bookings")
    if collection is not None:
        collection.insert_one(document)
        return document

    _memory_documents("bookings").insert(0, document)
    return document


def update_booking_status(booking_id: str, status: str) -> dict | None:
    collection = _collection("bookings")
    if collection is not None:
        collection.update_one({"_id": booking_id}, {"$set": {"status": status}})
        return collection.find_one({"_id": booking_id})

    current = _find_memory("bookings", booking_id)
    if current is None:
        return None
    updated = {**current, "status": status}
    return _upsert_memory("bookings", updated)


def list_notifications():
    collection = _collection("notifications")
    documents = (
        list(collection.find().sort("created_at", -1))
        if collection is not None
        else list(_memory_documents("notifications"))
    )
    return [map_notification(item) for item in documents]


def create_notification(document: dict) -> dict:
    collection = _collection("notifications")
    if collection is not None:
        collection.insert_one(document)
        return document
    _memory_documents("notifications").insert(0, document)
    return document


def delete_notification(notification_id: str) -> None:
    collection = _collection("notifications")
    if collection is not None:
        collection.delete_one({"_id": notification_id})
        return
    MEMORY_DB["notifications"] = [
        item for item in _memory_documents("notifications") if item["_id"] != notification_id
    ]


def create_booking_with_notification(document: dict) -> dict:
    booking = create_booking(document)
    create_notification(
        build_booking_notification(
            booking_id=booking["_id"],
            title="Booking created",
            message=(
                f'{booking["car_name"]} is reserved from '
                f'{booking["start_time"].strftime("%d.%m %H:%M")} '
                f'to {booking["end_time"].strftime("%d.%m %H:%M")}.'
            ),
        )
    )
    return booking


def get_tracking(car_id: str):
    collection = _collection("tracking")
    if collection is not None:
        document = collection.find_one({"car_id": car_id})
    else:
        document = next(
            (item for item in _memory_documents("tracking") if item["car_id"] == car_id),
            None,
        )

    if document is None:
        return None

    return map_tracking(document)


def get_admin_overview():
    users_collection = _collection("users")
    cars_collection = _collection("cars")
    bookings_collection = _collection("bookings")
    users = (
        list(users_collection.find().sort("_id", 1))
        if users_collection is not None
        else list(_memory_documents("users"))
    )
    cars = (
        list(cars_collection.find().sort("_id", 1))
        if cars_collection is not None
        else list(_memory_documents("cars"))
    )
    bookings = (
        list(bookings_collection.find().sort("start_time", -1))
        if bookings_collection is not None
        else list(_memory_documents("bookings"))
    )
    return map_admin_overview(users, cars, bookings)


def build_booking_notification(*, booking_id: str, title: str, message: str, type_: str = "booking") -> dict:
    return {
        "_id": f"notification-{booking_id}-{uuid4().hex[:6]}",
        "title": title,
        "message": message,
        "type": type_,
        "created_at": datetime.now(timezone.utc),
    }
