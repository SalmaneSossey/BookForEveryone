from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.routes import books, signbook
from core.config import get_settings


settings = get_settings()

app = FastAPI(title=settings.app_name)

origins = ["*"] if settings.allowed_origins == "*" else settings.allowed_origins.split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=settings.allowed_origins != "*",
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(books.router)
app.include_router(signbook.router)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "kitab-lil-jamie"}
