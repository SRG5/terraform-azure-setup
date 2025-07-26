import os

DB_NAME = os.getenv("DB_NAME", "simple_net_db")
DB_USER = os.getenv("DB_USER", "admin")
DB_PASSWORD = os.getenv("DB_PASSWORD", "admin123")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
IMAGE_URL = os.getenv("IMAGE_URL", "https://fallback-image-url")