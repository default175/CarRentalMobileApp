from __future__ import annotations

from .db import mongo
from .demo_seed import (
    demo_bookings,
    demo_cars,
    demo_notifications,
    demo_tracking,
    demo_users,
)

MEMORY_DB: dict[str, list[dict]] = {}


def ensure_seed_data() -> None:
    collections = {
        "users": demo_users(),
        "cars": demo_cars(),
        "bookings": demo_bookings(),
        "notifications": demo_notifications(),
        "tracking": demo_tracking(),
    }

    if not mongo.available or mongo.db is None:
        for name, items in collections.items():
            MEMORY_DB.setdefault(name, items)
        return

    for name, items in collections.items():
        collection = mongo.db[name]
        for item in items:
            collection.replace_one({"_id": item["_id"]}, item, upsert=True)
