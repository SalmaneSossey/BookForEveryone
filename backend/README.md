# Backend

FastAPI sample backend for the KitabLilJamie MVP. Keep Python dependencies isolated in `backend/.venv`; do not install backend packages into the global interpreter.

## Setup

```bash
cd backend
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
```

Activation is optional. The project commands call the venv binaries directly:

```bash
make test
make run
```

The development server runs at `http://127.0.0.1:8000`.

## Endpoints

- `GET /health`
- `GET /api/books`
- `GET /api/books/{book_id}`
- `GET /api/books/{book_id}/content?page=1`
- `POST /api/signbook/text-to-glosses`

## Docker

Docker Desktop can build and run the API from the repository root context:

```bash
docker compose -f backend/docker-compose.yml build
docker compose -f backend/docker-compose.yml up
```

The image copies only the backend source and the local sample-book JSON used by the API.
