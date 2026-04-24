from __future__ import annotations

from .db import mongo
from .demo_seed import (
    demo_bookings,
    demo_bookmarks,
    demo_cars,
    demo_favorites,
    demo_notifications,
    demo_payment_methods,
    demo_reviews,
    demo_tracking,
    demo_transactions,
    demo_users,
    demo_wallets,
)

MEMORY_DB: dict[str, list[dict]] = {}


def ensure_seed_data() -> None:
    collections = {
        "users": demo_users(),
        "cars": demo_cars(),
        "bookings": demo_bookings(),
        "notifications": demo_notifications(),
        "tracking": demo_tracking(),
        "wallets": demo_wallets(),
        "transactions": demo_transactions(),
        "favorites": demo_favorites(),
        "bookmarks": demo_bookmarks(),
        "reviews": demo_reviews(),
        "payment_methods": demo_payment_methods(),
    }

    if not mongo.available or mongo.db is None:
        for name, items in collections.items():
            MEMORY_DB.setdefault(name, items)
        return

    for name, items in collections.items():
        collection = mongo.db[name]
        for item in items:
            collection.replace_one({"_id": item["_id"]}, item, upsert=True)

    mongo.db.users.create_index("email", unique=True)
    mongo.db.cars.create_index([("category", 1), ("status", 1)])
    mongo.db.bookings.create_index([("user_id", 1), ("status", 1), ("start_time", -1)])
    mongo.db.tracking.create_index("car_id", unique=True)
    mongo.db.transactions.create_index([("user_id", 1), ("created_at", -1)])
    mongo.db.favorites.create_index([("user_id", 1), ("car_id", 1)], unique=True)
    mongo.db.bookmarks.create_index([("user_id", 1), ("car_id", 1)], unique=True)
