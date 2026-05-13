FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app/backend
COPY backend/requirements.txt .
RUN pip install -r requirements.txt

COPY backend/ /app/backend
COPY mobile/assets/data/sample_books.json /app/mobile/assets/data/sample_books.json

USER 10001

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
