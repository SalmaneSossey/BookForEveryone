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
    response = client.post(
        "/api/signbook/text-to-glosses",
        json={"text": "مرحبا يقرأ كتاب كلمة صوت يد شكرا"},
    )

    assert response.status_code == 200
    glosses = response.json()["glosses"]
    assert all(gloss["available"] for gloss in glosses)
    assert {gloss["sigmlPath"] for gloss in glosses} == {
        "alsl/مرحبا.sigml",
        "alsl/يقرأ.sigml",
        "alsl/كتاب.sigml",
        "alsl/كلمة.sigml",
        "alsl/صوت.sigml",
        "alsl/يد.sigml",
        "alsl/شكرا.sigml",
    }


def test_signbook_blender_story_glosses() -> None:
    response = client.post(
        "/api/signbook/text-to-glosses",
        json={"text": "see woman friends cook soup orange blender explodes"},
    )

    assert response.status_code == 200
    glosses = response.json()["glosses"]
    assert all(gloss["available"] for gloss in glosses)
    assert {gloss["sigmlPath"] for gloss in glosses} == {
        "cwasa_story/blenderStory.sigml"
    }
