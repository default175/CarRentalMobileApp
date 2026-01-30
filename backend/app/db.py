from __future__ import annotations

from pymongo.errors import PyMongoError
from pymongo import MongoClient

from .config import settings


class MongoDatabase:
    def __init__(self) -> None:
        self.available = True
        self._client = None
        self.db = None

        try:
            self._client = MongoClient(settings.mongodb_uri, serverSelectionTimeoutMS=1500)
            self._client.admin.command("ping")
            self.db = self._client[settings.mongodb_db]
        except PyMongoError:
            self.available = False


mongo = MongoDatabase()
