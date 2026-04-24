# Backend

Local REST API for the car rental demo application.

## Stack

- FastAPI
- PyMongo
- MongoDB Community Server

## Run

1. Install MongoDB Community Server locally.
2. Copy `.env.example` to `.env`.
3. Install requirements:
   `python -m pip install -r requirements.txt`
4. Start the API:
   `python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8080`

## Endpoints

- `GET /health`
- `GET /api/cars`
- `GET /api/bookings`
- `GET /api/notifications`
- `GET /api/admin/overview`
- `GET /api/tracking/{car_id}`
- `GET /api/wallet/{user_id}`
- `POST /api/wallet/top-up`
- `GET /api/transactions/{user_id}`
- `GET /api/favorites/{user_id}`
- `GET /api/bookmarks/{user_id}`
- `GET /api/payment-methods/{user_id}`
- `GET /api/reviews/{car_id}`
