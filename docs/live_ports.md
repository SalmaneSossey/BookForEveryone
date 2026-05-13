# Live Ports

Use this page during the pitch to test the local services from VS Code.

## Backend API

- FastAPI docs: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- Health check: [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health)
- Books list: [http://127.0.0.1:8000/api/books](http://127.0.0.1:8000/api/books)
- Arabic sample page: [http://127.0.0.1:8000/api/books/arabic-garden/content?page=1](http://127.0.0.1:8000/api/books/arabic-garden/content?page=1)
- OpenAPI JSON: [http://127.0.0.1:8000/openapi.json](http://127.0.0.1:8000/openapi.json)

## Current Commands

```bash
docker compose -f backend/docker-compose.yml ps
curl http://127.0.0.1:8000/health
curl "http://127.0.0.1:8000/api/books/arabic-garden/content?page=1"
```

## Stop / Restart

```bash
docker compose -f backend/docker-compose.yml down
docker compose -f backend/docker-compose.yml up -d
```
