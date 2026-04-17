from __future__ import annotations

from datetime import datetime, timezone
from uuid import uuid4

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .db import mongo
from .repositories import (
    authenticate_user,
    create_booking_with_notification,
    delete_car,
    delete_notification,
    get_admin_overview,
    get_tracking,
    get_user,
    list_documents,
    list_bookings,
    list_cars,
    list_notifications,
    register_user,
    save_document,
    save_car,
    save_user,
    toggle_user_blocked,
    update_booking_status,
)
from .schemas import (
    CreateBookingRequest,
    CreateReviewRequest,
    LoginRequest,
    RegisterRequest,
    SaveCarRequest,
    SaveUserRequest,
    UpdateBookingStatusRequest,
    WalletTopUpRequest,
)
from .mappers import map_booking, map_car, map_user
from .seed import ensure_seed_data

app = FastAPI(
    title="Car Rental Backend",
    version="0.1.0",
    description="Local MongoDB backend for the car rental Flutter application.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup() -> None:
    ensure_seed_data()


@app.get("/health")
def health() -> dict:
    return {
        "status": "ok",
        "mongodb_uri": settings.mongodb_uri,
        "mongodb_db": settings.mongodb_db,
        "mongodb_available": mongo.available,
    }


@app.get("/api/cars")
def cars():
    return list_cars()


@app.get("/api/bookings")
def bookings():
    return list_bookings()


@app.post("/api/bookings")
def add_booking(payload: CreateBookingRequest):
    document = {
        "_id": f"booking-{uuid4().hex[:8]}",
        "user_id": payload.user_id,
        "user_name": payload.user_name,
        "car_id": payload.car_id,
        "car_name": payload.car_name,
        "start_time": payload.start_time.astimezone(timezone.utc),
        "end_time": payload.end_time.astimezone(timezone.utc),
        "status": "created",
        "total_price": payload.total_price,
        "distance_km": 0,
        "route_summary": "Awaiting vehicle pickup",
    }
    return create_booking_with_notification(document)


@app.patch("/api/bookings/{booking_id}/status")
def patch_booking_status(booking_id: str, payload: UpdateBookingStatusRequest):
    booking = update_booking_status(booking_id, payload.status)
    if booking is None:
        raise HTTPException(status_code=404, detail="Booking not found.")
    return map_booking(booking)


@app.get("/api/notifications")
def notifications():
    return list_notifications()


@app.delete("/api/notifications/{notification_id}", status_code=204)
def remove_notification(notification_id: str):
    delete_notification(notification_id)
    return None


@app.get("/api/admin/overview")
def admin_overview():
    return get_admin_overview()


@app.post("/api/auth/register")
def register(payload: RegisterRequest):
    try:
        user = register_user(
            {
                "_id": f"user-{uuid4().hex[:8]}",
                "name": payload.name.strip(),
                "email": payload.email.strip().lower(),
                "phone": payload.phone.strip(),
                "role": "admin"
                if payload.email.strip().lower() == "admin@demo.app"
                else "user",
                "license_number": payload.license_number.strip()
                if payload.license_number
                else None,
                "photo_url": None,
                "blocked": False,
                "created_at": datetime.now(timezone.utc),
                "password": payload.password,
            }
        )
    except ValueError as error:
        raise HTTPException(status_code=409, detail=str(error)) from error

    return map_user(user)


@app.post("/api/auth/login")
def login(payload: LoginRequest):
    user = authenticate_user(payload.email.strip().lower(), payload.password)
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid email or password.")
    if user.get("blocked", False):
        raise HTTPException(status_code=403, detail="User account is blocked.")
    return map_user(user)


@app.put("/api/users/{user_id}")
def put_user(user_id: str, payload: SaveUserRequest):
    current = get_user(user_id)
    if current is None:
        current = {
            "_id": user_id,
            "created_at": datetime.now(timezone.utc),
            "blocked": False,
            "password": payload.password or "demo123",
        }

    updated = {
        **current,
        "name": payload.name.strip(),
        "email": payload.email.strip().lower(),
        "phone": payload.phone.strip(),
        "role": payload.role,
        "license_number": payload.license_number.strip()
        if payload.license_number
        else None,
        "photo_url": payload.photo_url,
    }
    return map_user(save_user(updated))


@app.patch("/api/users/{user_id}/toggle-block")
def patch_user_block(user_id: str):
    user = toggle_user_blocked(user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found.")
    return map_user(user)


@app.put("/api/cars/{car_id}")
def put_car(car_id: str, payload: SaveCarRequest):
    document = {
        "_id": car_id,
        "brand": payload.brand.strip(),
        "model": payload.model.strip(),
        "year": payload.year,
        "type": payload.type.strip(),
        "category": payload.category.strip(),
        "price_per_hour": payload.price_per_hour,
        "status": payload.status,
        "battery_level": payload.battery_level,
        "range_km": payload.range_km,
        "seats": payload.seats,
        "transmission": payload.transmission.strip(),
        "color": payload.color.strip(),
        "description": payload.description.strip(),
        "features": [item.strip() for item in payload.features if item.strip()],
        "fuel_type": payload.fuel_type.strip(),
        "gas_level": payload.gas_level,
        "engine_volume": payload.engine_volume,
        "mileage_km": payload.mileage_km,
        "drive": payload.drive.strip(),
        "registered": payload.registered,
        "image_url": payload.image_url.strip() if payload.image_url else None,
        "has_gps_signal": payload.has_gps_signal,
        "location": {
            "lat": payload.location["lat"],
            "lng": payload.location["lng"],
        },
    }
    return map_car(save_car(document))


@app.delete("/api/cars/{car_id}", status_code=204)
def remove_car(car_id: str):
    delete_car(car_id)
    return None


@app.get("/api/tracking/{car_id}")
def tracking(car_id: str):
    item = get_tracking(car_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Tracking record not found.")

    return item


@app.get("/api/wallet/{user_id}")
def wallet(user_id: str):
    documents = list_documents("wallets", {"user_id": user_id})
    if not documents:
        document = {
            "_id": f"wallet-{user_id}",
            "user_id": user_id,
            "balance": 0,
            "currency": "KZT",
            "updated_at": datetime.now(timezone.utc),
        }
        return save_document("wallets", document)
    return documents[0]


@app.get("/api/transactions/{user_id}")
def transactions(user_id: str):
    return list_documents("transactions", {"user_id": user_id}, [("created_at", -1)])


@app.post("/api/wallet/top-up")
def wallet_top_up(payload: WalletTopUpRequest):
    wallet_documents = list_documents("wallets", {"user_id": payload.user_id})
    wallet_document = wallet_documents[0] if wallet_documents else {
        "_id": f"wallet-{payload.user_id}",
        "user_id": payload.user_id,
        "balance": 0,
        "currency": "KZT",
        "updated_at": datetime.now(timezone.utc),
    }
    wallet_document = {
        **wallet_document,
        "balance": wallet_document.get("balance", 0) + payload.amount,
        "updated_at": datetime.now(timezone.utc),
    }
    save_document("wallets", wallet_document)
    save_document(
        "transactions",
        {
            "_id": f"transaction-{uuid4().hex[:8]}",
            "user_id": payload.user_id,
            "booking_id": None,
            "type": "wallet_top_up",
            "amount": payload.amount,
            "status": "paid",
            "payment_method": payload.payment_method,
            "created_at": datetime.now(timezone.utc),
        },
    )
    return wallet_document


@app.get("/api/favorites/{user_id}")
def favorites(user_id: str):
    return list_documents("favorites", {"user_id": user_id}, [("created_at", -1)])


@app.get("/api/bookmarks/{user_id}")
def bookmarks(user_id: str):
    return list_documents("bookmarks", {"user_id": user_id}, [("created_at", -1)])


@app.get("/api/payment-methods/{user_id}")
def payment_methods(user_id: str):
    return list_documents("payment_methods", {"user_id": user_id}, [("created_at", -1)])


@app.get("/api/reviews/{car_id}")
def reviews(car_id: str):
    return list_documents("reviews", {"car_id": car_id}, [("created_at", -1)])


@app.post("/api/reviews")
def add_review(payload: CreateReviewRequest):
    document = {
        "_id": f"review-{uuid4().hex[:8]}",
        "user_id": payload.user_id,
        "user_name": payload.user_name,
        "car_id": payload.car_id,
        "car_name": payload.car_name,
        "rating": max(1, min(5, payload.rating)),
        "comment": payload.comment.strip(),
        "created_at": datetime.now(timezone.utc),
    }
    return save_document("reviews", document)
