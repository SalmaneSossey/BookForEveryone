import sys
from pathlib import Path

from fastapi.testclient import TestClient

BACKEND_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))

from main import app  # noqa: E402


client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_books_list_returns_demo_books() -> None:
    response = client.get("/api/books")

    assert response.status_code == 200
    books = response.json()
    assert len(books) >= 6
    assert "pages" not in books[0]


def test_book_content_returns_page() -> None:
    response = client.get("/api/books/arabic-garden/content?page=1")

    assert response.status_code == 200
    payload = response.json()
    assert payload["bookId"] == "arabic-garden"
    assert payload["pageNumber"] == 1
    assert "القراءة" in payload["content"]


def test_signbook_glosses() -> None:
    response = client.post("/api/signbook/text-to-glosses", json={"text": "كتاب صوت"})

    assert response.status_code == 200
    glosses = response.json()["glosses"]
    assert glosses[0]["available"] is True
    assert glosses[0]["sigmlPath"] == "additions_lsm/kitab.sigml"
