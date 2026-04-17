from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel


class GeoPointSchema(BaseModel):
    lat: float
    lng: float


class CarSchema(BaseModel):
    id: str
    brand: str
    model: str
    year: int
    type: str
    category: str | None = None
    price_per_hour: float
    status: str
    battery_level: int
    range_km: int
    seats: int | None = None
    transmission: str | None = None
    color: str | None = None
    description: str | None = None
    features: list[str] = []
    fuel_type: str = "Petrol"
    gas_level: int | None = None
    engine_volume: float | None = None
    mileage_km: int = 0
    drive: str = "front"
    registered: bool = True
    image_url: str | None = None
    has_gps_signal: bool | None = None
    location: GeoPointSchema


class BookingSchema(BaseModel):
    id: str
    user_id: str
    user_name: str | None = None
    car_id: str
    car_name: str
    start_time: datetime
    end_time: datetime
    status: str
    total_price: float
    distance_km: float
    route_summary: str | None = None


class NotificationSchema(BaseModel):
    id: str
    title: str
    message: str
    type: str
    created_at: datetime


class UserSchema(BaseModel):
    id: str
    name: str
    email: str
    phone: str
    role: str
    license_number: str | None = None
    photo_url: str | None = None
    created_at: datetime | None = None
    blocked: bool


class TrackingSchema(BaseModel):
    car_id: str
    lat: float
    lng: float
    speed_kph: float
    is_inside_geofence: bool
    geofence_name: str
    distance_km: float
    updated_at: str
    route: list[GeoPointSchema]


class AdminOverviewSchema(BaseModel):
    users: list[UserSchema]
    cars: list[CarSchema]
    bookings: list[BookingSchema]
    active_trips: int


class CreateBookingRequest(BaseModel):
    user_id: str
    user_name: str
    car_id: str
    car_name: str
    start_time: datetime
    end_time: datetime
    total_price: float


class RegisterRequest(BaseModel):
    name: str
    email: str
    phone: str
    password: str
    license_number: str | None = None


class LoginRequest(BaseModel):
    email: str
    password: str


class SaveUserRequest(BaseModel):
    name: str
    email: str
    phone: str
    role: str
    license_number: str | None = None
    photo_url: str | None = None
    created_at: datetime | None = None
    blocked: bool = False
    password: str | None = None


class SaveCarRequest(BaseModel):
    brand: str
    model: str
    year: int
    type: str
    category: str
    price_per_hour: float
    status: str
    battery_level: int
    range_km: int
    seats: int
    transmission: str
    color: str
    description: str
    features: list[str]
    fuel_type: str = "Petrol"
    gas_level: int | None = None
    engine_volume: float | None = None
    mileage_km: int = 0
    drive: str = "front"
    registered: bool = True
    image_url: str | None = None
    has_gps_signal: bool = True
    location: GeoPointSchema


class UpdateBookingStatusRequest(BaseModel):
    status: str


class WalletTopUpRequest(BaseModel):
    user_id: str
    amount: float
    payment_method: str = "Wallet card"


class CreateReviewRequest(BaseModel):
    user_id: str
    user_name: str
    car_id: str
    car_name: str
    rating: int
    comment: str
