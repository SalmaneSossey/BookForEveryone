import json
from functools import lru_cache
from pathlib import Path
from typing import Any


DATA_PATH = (
    Path(__file__).resolve().parents[2]
    / "mobile"
    / "assets"
    / "data"
    / "sample_books.json"
)


class BookStore:
    def __init__(self, data_path: Path = DATA_PATH) -> None:
        self.data_path = data_path

    def list_books(self) -> list[dict[str, Any]]:
        return [_metadata(book) for book in self._load_books()]

    def get_book(self, book_id: str) -> dict[str, Any] | None:
        for book in self._load_books():
            if book["id"] == book_id:
                return _metadata(book)
        return None

    def get_page(self, book_id: str, page_number: int) -> dict[str, Any] | None:
        for book in self._load_books():
            if book["id"] != book_id:
                continue
            for page in book.get("pages", []):
                if page.get("pageNumber") == page_number:
                    return {
                        "bookId": book_id,
                        "pageNumber": page.get("pageNumber", page_number),
                        "content": page.get("content", ""),
                        "wordCount": page.get("wordCount", 0),
                    }
        return None

    def _load_books(self) -> list[dict[str, Any]]:
        payload = json.loads(self.data_path.read_text(encoding="utf-8"))
        books = payload.get("books", [])
        if not isinstance(books, list):
            return []
        return books


def _metadata(book: dict[str, Any]) -> dict[str, Any]:
    return {key: value for key, value in book.items() if key != "pages"}


@lru_cache
def get_book_store() -> BookStore:
    return BookStore()
