from fastapi import APIRouter, HTTPException, Query

from models.schemas import Book, BookPage
from services.book_store import get_book_store

router = APIRouter(prefix="/api/books", tags=["books"])


@router.get("", response_model=list[Book], response_model_by_alias=True)
def list_books(
    language: str | None = Query(default=None),
    category: str | None = Query(default=None),
) -> list[dict]:
    books = get_book_store().list_books()
    if language:
        books = [book for book in books if book.get("language") == language]
    if category:
        books = [book for book in books if book.get("category") == category]
    return books


@router.get("/{book_id}", response_model=Book, response_model_by_alias=True)
def get_book(book_id: str) -> dict:
    book = get_book_store().get_book(book_id)
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return book


@router.get("/{book_id}/content", response_model=BookPage, response_model_by_alias=True)
def get_book_content(book_id: str, page: int = Query(default=1, ge=1)) -> dict:
    book_page = get_book_store().get_page(book_id, page)
    if book_page is None:
        raise HTTPException(status_code=404, detail="Book page not found")
    return book_page
