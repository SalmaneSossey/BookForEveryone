from pydantic import BaseModel, Field


class BookPage(BaseModel):
    book_id: str = Field(alias="bookId")
    page_number: int = Field(alias="pageNumber")
    content: str
    word_count: int = Field(alias="wordCount")


class Book(BaseModel):
    id: str
    title: str
    title_ar: str | None = Field(default=None, alias="titleAr")
    author: str
    language: str
    category: str
    description: str
    total_pages: int = Field(alias="totalPages")
    cover_emoji: str = Field(alias="coverEmoji")
    accent_color: str = Field(alias="accentColor")
    has_sigml: bool = Field(alias="hasSigml")
    sigml_coverage: float = Field(alias="sigmlCoverage")


class BookWithPages(Book):
    pages: list[BookPage]


class GlossEntry(BaseModel):
    word: str
    gloss: str
    available: bool
    sigml_path: str | None = Field(default=None, alias="sigmlPath")


class TextToGlossRequest(BaseModel):
    text: str


class TextToGlossResponse(BaseModel):
    glosses: list[GlossEntry]
