# KitabLilJamie - Architecture.md

**Project:** KitabLilJamie / كتاب للجميع  
**Context:** Rabat Smart Book Hackathon 2026  
**Goal:** Build an accessible mobile library for blind/visually impaired and deaf users in Morocco.  
**Development environment:** VS Code + WSL + Codex  
**Main stack:** Flutter mobile app + FastAPI backend + PostgreSQL + ChromaDB + Hive offline cache

---

## 1. Product Vision

KitabLilJamie is a mobile accessible digital library with two primary accessibility modes:

1. **Blind / visually impaired mode**
   - Voice-first experience.
   - Assistant named **Samia**.
   - User can speak naturally to choose books, start reading, pause, continue, search, ask questions, or scan a physical page.
   - The app reads books using TTS and responds using voice.

2. **Deaf mode**
   - Visual-first experience.
   - Books are converted into sign-language-friendly glosses.
   - A 3D avatar signs the content using **SiGML + CWASA**.
   - Interface avoids audio dependency and uses visual/haptic feedback.

3. **Explore mode**
   - A demo/discovery mode for judges and general users.
   - Shows both accessibility experiences without forcing a profile choice.

The MVP must feel impressive in a hackathon demo, even if some advanced components are mocked or partially implemented.

---

## 2. MVP Priorities

The app should be developed in phases. Do not try to implement every advanced feature at once.

### Phase 1 - Demo Foundation

Must have:

- Flutter onboarding screen.
- User profile selection:
  - Blind mode.
  - Deaf mode.
  - Explore mode.
- Home screen with a small list of real books.
- Local JSON seed data for books.
- Navigation between screens using `go_router`.
- Clean accessible UI.
- Hive setup for profile and reading progress.

### Phase 2 - Blind Mode / Samia

Must have:

- Voice-first UI screen for Samia.
- Text input fallback for testing inside emulator.
- TTS reading of book pages.
- Commands:
  - Start reading.
  - Pause.
  - Continue.
  - Next page.
  - Previous page.
  - Search book.
- Reading progress saved locally.

Nice for demo:

- STT using native speech recognition or backend Whisper.
- OCR screen using camera + Google ML Kit.
- RAG chat with book content.

### Phase 3 - Deaf Mode / SignBook

Must have:

- Visual book grid.
- SignBook reader screen.
- Text panel showing current sentence/page.
- Gloss conversion service.
- Avatar area using WebView.
- If CWASA integration is difficult, use a placeholder animated avatar area first.

Nice for demo:

- Real CWASA WebView loading local HTML.
- Local SiGML lookup using `_index.json`.
- Fallback to fingerspelling if gloss not found.
- Haptic feedback on sentence/page changes.

### Phase 4 - Backend Integration

Must have:

- FastAPI backend with `/health`.
- Books endpoints.
- TTS endpoint or client-native TTS fallback.
- SignBook text-to-gloss endpoint.

Nice for demo:

- PostgreSQL storage.
- ChromaDB embeddings.
- Mistral-powered RAG.
- faster-whisper transcription.

---

## 3. High-Level Architecture

```text
KitabLilJamie
│
├── Flutter Mobile App
│   ├── Onboarding
│   ├── Blind Mode: Samia
│   │   ├── Voice commands
│   │   ├── TTS reading
│   │   ├── STT transcription
│   │   ├── OCR scan
│   │   └── RAG chat
│   │
│   ├── Deaf Mode: SignBook
│   │   ├── Visual library
│   │   ├── Text-to-gloss
│   │   ├── SiGML lookup
│   │   ├── CWASA avatar WebView
│   │   └── Haptic feedback
│   │
│   ├── Explore Mode
│   └── Local Storage: Hive
│
├── FastAPI Backend
│   ├── Books API
│   ├── Samia Chat API
│   ├── Search API
│   ├── STT API
│   ├── TTS API
│   ├── Text-to-gloss API
│   └── OCR fallback API
│
├── PostgreSQL
│   ├── books
│   ├── book_pages
│   └── categories
│
├── ChromaDB
│   └── semantic book chunks for RAG
│
└── Assets
    ├── sample_books.json
    ├── SiGML files
    └── CWASA avatar files
```

---

## 4. Repository Structure

Use a monorepo structure:

```text
kitab_lil_jamie/
│
├── architecture.md
├── README.md
├── .gitignore
│
├── mobile/
│   ├── pubspec.yaml
│   ├── lib/
│   ├── assets/
│   └── test/
│
├── backend/
│   ├── main.py
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── api/
│   ├── core/
│   ├── models/
│   ├── services/
│   ├── scripts/
│   ├── data/
│   └── chromadb_data/
│
└── docs/
    ├── demo_script.md
    ├── technical_choices.md
    └── future_work.md
```

---

## 5. Flutter Architecture

### 5.1 Flutter Folder Structure

```text
mobile/lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── voice_commands.dart
│   │
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── book.dart
│   │   ├── book_page.dart
│   │   ├── reading_progress.dart
│   │   ├── chat_message.dart
│   │   └── gloss_entry.dart
│   │
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── hive_service.dart
│   │   ├── offline_manager.dart
│   │   ├── tts_service.dart
│   │   ├── stt_service.dart
│   │   ├── vad_service.dart
│   │   └── ocr_service.dart
│   │
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_text_styles.dart
│   │
│   └── widgets/
│       ├── accessible_button.dart
│       ├── adaptive_bottom_nav.dart
│       └── loading_feedback.dart
│
├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   │   └── onboarding_screen.dart
│   │   └── bloc/
│   │       └── onboarding_bloc.dart
│   │
│   ├── home/
│   │   ├── screens/
│   │   │   ├── home_blind_screen.dart
│   │   │   ├── home_deaf_screen.dart
│   │   │   └── home_explore_screen.dart
│   │   └── widgets/
│   │       └── book_card.dart
│   │
│   ├── samia/
│   │   ├── screens/
│   │   │   ├── samia_screen.dart
│   │   │   ├── reading_screen.dart
│   │   │   └── search_results_screen.dart
│   │   ├── widgets/
│   │   │   ├── chat_bubble.dart
│   │   │   ├── voice_indicator.dart
│   │   │   └── reading_text_view.dart
│   │   ├── bloc/
│   │   │   ├── samia_bloc.dart
│   │   │   ├── reading_bloc.dart
│   │   │   └── reading_state.dart
│   │   └── services/
│   │       └── samia_voice_controller.dart
│   │
│   ├── signbook/
│   │   ├── screens/
│   │   │   └── signbook_reader_screen.dart
│   │   ├── widgets/
│   │   │   ├── cwasa_avatar_widget.dart
│   │   │   ├── sign_text_panel.dart
│   │   │   └── sign_controls.dart
│   │   ├── bloc/
│   │   │   └── signbook_bloc.dart
│   │   └── services/
│   │       ├── sigml_service.dart
│   │       └── text_to_gloss_service.dart
│   │
│   └── scan/
│       ├── screens/
│       │   └── scan_screen.dart
│       └── bloc/
│           └── scan_bloc.dart
│
└── assets/
    ├── data/
    │   └── sample_books.json
    ├── sigml/
    │   ├── _index.json
    │   ├── alphabet/
    │   └── additions_lsm/
    └── cwasa/
        └── signbook_avatar.html
```

### 5.2 Flutter Dependencies

Add these gradually. Start with only the required packages.

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0

  # Navigation
  go_router: ^14.0.0

  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0

  # Local storage
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0

  # Voice / audio
  speech_to_text: ^7.0.0
  flutter_tts: ^4.2.0
  just_audio: ^0.9.40

  # Camera / OCR
  camera: ^0.11.0
  google_mlkit_text_recognition: ^0.14.0

  # WebView for CWASA avatar
  flutter_inappwebview: ^6.0.0

  # UI and feedback
  flutter_animate: ^4.5.0
  vibration: ^2.0.0
  permission_handler: ^11.3.0

  # Serialization
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
  json_serializable: ^6.8.0
```

### 5.3 Flutter Assets

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/data/sample_books.json
    - assets/sigml/
    - assets/sigml/_index.json
    - assets/sigml/alphabet/
    - assets/sigml/additions_lsm/
    - assets/cwasa/
    - assets/cwasa/signbook_avatar.html
```

---

## 6. Flutter Routing

Use `go_router`.

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/samia',
      builder: (context, state) => const SamiaScreen(),
    ),
    GoRoute(
      path: '/home-deaf',
      builder: (context, state) => const HomeDeafScreen(),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const HomeExploreScreen(),
    ),
    GoRoute(
      path: '/reading/:bookId',
      builder: (context, state) => ReadingScreen(
        bookId: state.pathParameters['bookId']!,
      ),
    ),
    GoRoute(
      path: '/signbook/:bookId',
      builder: (context, state) => SignBookReaderScreen(
        bookId: state.pathParameters['bookId']!,
      ),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanScreen(),
    ),
  ],
);
```

Later, replace the initial route logic with profile-based redirection from Hive.

---

## 7. Core Data Models

### 7.1 User Profile

```dart
enum UserProfileType {
  blind,
  deaf,
  explore,
}

class UserProfile {
  final UserProfileType type;
  final String? preferredLanguage;
  final DateTime createdAt;

  UserProfile({
    required this.type,
    this.preferredLanguage,
    required this.createdAt,
  });
}
```

### 7.2 Book

```dart
class Book {
  final String id;
  final String title;
  final String? titleAr;
  final String author;
  final String language;
  final String category;
  final String description;
  final int totalPages;
  final String coverEmoji;
  final String accentColor;
  final bool hasSigml;
  final double sigmlCoverage;

  Book({
    required this.id,
    required this.title,
    this.titleAr,
    required this.author,
    required this.language,
    required this.category,
    required this.description,
    required this.totalPages,
    required this.coverEmoji,
    required this.accentColor,
    required this.hasSigml,
    required this.sigmlCoverage,
  });
}
```

### 7.3 Book Page

```dart
class BookPage {
  final String bookId;
  final int pageNumber;
  final String content;
  final List<GlossEntry>? glosses;
  final int wordCount;

  BookPage({
    required this.bookId,
    required this.pageNumber,
    required this.content,
    this.glosses,
    required this.wordCount,
  });
}
```

### 7.4 Gloss Entry

```dart
class GlossEntry {
  final String word;
  final String gloss;
  final bool available;
  final String? sigmlPath;

  GlossEntry({
    required this.word,
    required this.gloss,
    required this.available,
    this.sigmlPath,
  });
}
```

---

## 8. Backend Architecture

### 8.1 Backend Folder Structure

```text
backend/
├── main.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .env.example
│
├── api/
│   ├── __init__.py
│   └── routes/
│       ├── __init__.py
│       ├── books.py
│       ├── samia.py
│       ├── signbook.py
│       ├── stt.py
│       ├── tts.py
│       └── scan.py
│
├── core/
│   ├── config.py
│   └── security.py
│
├── models/
│   ├── database.py
│   └── schemas.py
│
├── services/
│   ├── __init__.py
│   ├── llm_service.py
│   ├── rag_service.py
│   ├── tts_service.py
│   ├── stt_service.py
│   ├── signbook_service.py
│   └── language_service.py
│
├── scripts/
│   └── seed_books.py
│
├── data/
│   └── books/
│
└── chromadb_data/
```

### 8.2 Backend Dependencies

```txt
fastapi==0.115.0
uvicorn[standard]==0.32.0
sqlalchemy[asyncio]==2.0.35
asyncpg==0.30.0
pydantic-settings==2.6.0
python-multipart==0.0.17
httpx==0.28.0

# AI / NLP
mistralai==1.2.0
faster-whisper==1.1.0
edge-tts==6.1.12
sentence-transformers==3.3.0
chromadb==0.5.20

# Arabic text utilities
pyarabic>=0.6.15

# Optional
redis==5.2.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
```

---

## 9. Backend API Endpoints

### General

| Method | Route | Description |
|---|---|---|
| GET | `/health` | Check backend status |

### Books

| Method | Route | Description |
|---|---|---|
| GET | `/api/books` | List books, filter by language/category |
| GET | `/api/books/{book_id}` | Get one book metadata |
| GET | `/api/books/{book_id}/content?page=1` | Get one page of a book |
| GET | `/api/books/{book_id}/download` | Download full book for offline cache |

### Samia / Blind Mode

| Method | Route | Description |
|---|---|---|
| POST | `/api/samia/chat` | Ask Samia a question using RAG + LLM |
| POST | `/api/samia/chat/stream` | Streaming Samia response using SSE |
| GET | `/api/samia/search?q=...` | Search books by voice/text query |
| POST | `/api/stt/transcribe` | Audio to text using faster-whisper |
| POST | `/api/tts/synthesize` | Text to speech audio using Edge TTS |
| POST | `/api/scan/ocr` | OCR fallback from image to text |

### SignBook / Deaf Mode

| Method | Route | Description |
|---|---|---|
| POST | `/api/signbook/text-to-glosses` | Convert text into gloss entries |

---

## 10. PostgreSQL Schema

### 10.1 Books Table

```sql
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500) NOT NULL,
    title_ar VARCHAR(500),
    author VARCHAR(300),
    author_ar VARCHAR(300),
    language VARCHAR(10) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    description_ar TEXT,
    total_pages INTEGER NOT NULL,
    cover_emoji VARCHAR(10),
    accent_color VARCHAR(7),
    has_sigml BOOLEAN DEFAULT FALSE,
    sigml_coverage FLOAT DEFAULT 0,
    is_free BOOLEAN DEFAULT TRUE,
    source VARCHAR(200),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### 10.2 Book Pages Table

```sql
CREATE TABLE book_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    page_number INTEGER NOT NULL,
    content TEXT NOT NULL,
    content_clean TEXT,
    glosses JSONB,
    word_count INTEGER,
    UNIQUE(book_id, page_number)
);
```

### 10.3 Categories Table

```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    icon VARCHAR(10),
    color VARCHAR(7)
);
```

### 10.4 Indexes

```sql
CREATE INDEX idx_books_language ON books(language);
CREATE INDEX idx_books_category ON books(category);
CREATE INDEX idx_book_pages_book ON book_pages(book_id);
CREATE INDEX idx_book_pages_number ON book_pages(book_id, page_number);
```

---

## 11. Local Storage with Hive

Use Hive for:

- User profile.
- Cached books.
- Reading progress.
- Chat history.

Recommended Hive boxes:

```text
profile_box
cached_books_box
reading_progress_box
chat_history_box
settings_box
```

### Cached Book Shape

```dart
class CachedBook {
  final String id;
  final String title;
  final String? titleAr;
  final String author;
  final String language;
  final int totalPages;
  final String coverEmoji;
  final String accentColor;
  final Map<int, String> pages;
  final Map<int, List<Map<String, dynamic>>>? glosses;
  final DateTime downloadedAt;
}
```

---

## 12. Data Strategy

### 12.1 Server Storage

PostgreSQL stores:

- Book metadata.
- Book pages.
- Page-level glosses.
- Categories.

ChromaDB stores:

- Semantic chunks of books.
- Multilingual embeddings.
- Metadata for RAG search.

### 12.2 Client Storage

Hive stores:

- Books downloaded for offline use.
- Current reading progress.
- User profile.
- Samia chat history.

### 12.3 Seed Books for Demo

Use 10 real books or excerpts:

- At least 5 Arabic books.
- At least 3 French books.
- At least 2 Moroccan-related books/stories.
- No Lorem Ipsum.
- Text should be paginated.
- Use public domain or authorized excerpts only.

Possible sources:

- Hindawi Foundation.
- Arabic Wikisource.
- French Wikisource.
- Project Gutenberg.
- Gallica / BnF.
- Moroccan oral tradition stories, if rights are clear.

Important copyright note:

- Do **not** assume that every famous book is public domain.
- For a hackathon demo, prefer short public-domain extracts or internally prepared sample stories.

---

## 13. Blind Mode Flow

```text
User says: "Read Al-Ayyam for me"
│
▼
VAD detects speech
│
▼
STT converts audio to text
│
▼
SamiaVoiceController detects intent = read book
│
▼
Search API finds matching book
│
▼
TTS says: "I found Al-Ayyam by Taha Hussein"
│
▼
GoRouter opens /reading/{bookId}
│
▼
ReadingScreen loads page 1
│
▼
TTS reads text
│
▼
UI highlights current word or sentence
│
▼
Hive saves reading progress
```

### Blind Mode Commands

```text
start reading
pause
continue
stop
next page
previous page
repeat
search for [book]
scan page
ask question
```

For Arabic/Darija demo, support simple phrases too:

```text
قرا ليا
حبس
كمل
الصفحة الموالية
رجع
قلب على
```

---

## 14. Deaf Mode Flow

```text
User opens book from visual grid
│
▼
GoRouter opens /signbook/{bookId}
│
▼
SignBookBloc loads page content
│
▼
Backend returns text + glosses if available
│
▼
SigmlService checks each gloss in _index.json
│
├── Found: load matching .sigml file
│
└── Missing: fallback to fingerspelling or visual text
│
▼
CwasaAvatarWidget plays concatenated SiGML
│
▼
UI highlights current sentence/word
│
▼
Vibration gives haptic feedback
│
▼
Hive saves progress
```

---

## 15. CWASA / SiGML Strategy

### MVP Strategy

Start with:

- A WebView area that loads `assets/cwasa/signbook_avatar.html`.
- A simple `playSigml(sigmlString)` JavaScript bridge.
- A placeholder avatar if CWASA fails.

### Gloss Lookup

`assets/sigml/_index.json` should map glosses to files:

```json
{
  "مرحبا": "additions_lsm/marhaban.sigml",
  "كتاب": "additions_lsm/kitab.sigml",
  "أنا": "additions_lsm/ana.sigml"
}
```

### Fallback Rules

If a word/gloss is missing:

1. Try normalized Arabic text without diacritics.
2. Try a synonym/gloss mapping.
3. Use fingerspelling.
4. Show the word visually with an icon.

---

## 16. Docker Compose

Use this for backend development:

```yaml
version: "3.9"

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://kitab:kitab@db:5432/kitabliljamie
      - REDIS_URL=redis://redis:6379
      - MISTRAL_API_KEY=${MISTRAL_API_KEY}
    depends_on:
      - db
      - redis
    volumes:
      - ./data:/app/data
      - ./chromadb_data:/app/chromadb_data

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: kitabliljamie
      POSTGRES_USER: kitab
      POSTGRES_PASSWORD: kitab
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

---

## 17. Development Commands

### 17.1 WSL Setup

```bash
mkdir kitab_lil_jamie
cd kitab_lil_jamie
mkdir mobile backend docs
```

### 17.2 Flutter

```bash
cd mobile
flutter create .
flutter pub get
flutter run
```

### 17.3 Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 17.4 Docker

```bash
cd backend
docker compose up --build
```

### 17.5 Health Check

```bash
curl http://localhost:8000/health
```

Expected:

```json
{
  "status": "ok",
  "version": "1.0"
}
```

---

## 18. Coding Rules for Codex

When using Codex in VS Code, follow these rules:

1. Do not generate the whole project in one huge step.
2. Create files phase by phase.
3. Keep the app runnable after every phase.
4. Prefer simple working code over complex incomplete architecture.
5. Use clear folder structure exactly as described in this file.
6. Add comments only when they explain non-obvious logic.
7. Avoid hardcoding backend URLs everywhere; use `api_constants.dart`.
8. Every feature must have a screen, service, and state-management structure when needed.
9. Use mock/local data first, then connect backend.
10. For hackathon demo, prioritize visible working experience over perfect backend complexity.
11. Use accessibility best practices:
    - Large buttons.
    - High contrast.
    - Minimum tap target around 48x48 dp.
    - Voice feedback in blind mode.
    - No audio-only instruction in deaf mode.
    - Haptic/visual feedback in deaf mode.
12. Do not remove existing files without reason.
13. If a dependency causes build errors, simplify and replace with a stable fallback.

---

## 19. Suggested Codex Work Plan

Use the following order.

### Step 1 - Create Flutter Base

Ask Codex:

```text
Create the Flutter project structure for KitabLilJamie according to architecture.md. Implement main.dart, app.dart, app theme, onboarding screen, and three routes: /samia, /home-deaf, /explore. Use go_router. Keep it runnable.
```

### Step 2 - Add Models and Local JSON Books

Ask Codex:

```text
Add Book, BookPage, UserProfile, ReadingProgress, and GlossEntry models. Add sample_books.json with 6 demo books. Create a local BookRepository that loads books from assets/data/sample_books.json.
```

### Step 3 - Build Deaf Home + SignBook Placeholder

Ask Codex:

```text
Implement HomeDeafScreen as a visual grid of books. Implement SignBookReaderScreen with an avatar placeholder, text panel, next/previous page controls, and haptic feedback hooks.
```

### Step 4 - Build Samia Reading Flow

Ask Codex:

```text
Implement SamiaScreen and ReadingScreen. Use flutter_tts to read book pages aloud. Add buttons for read, pause, continue, next page, previous page. Save reading progress in Hive.
```

### Step 5 - Backend Skeleton

Ask Codex:

```text
Create the FastAPI backend skeleton according to architecture.md. Implement /health, /api/books, /api/books/{book_id}, and /api/books/{book_id}/content using in-memory sample data first.
```

### Step 6 - Connect Flutter to Backend

Ask Codex:

```text
Add ApiService using Dio. Make BookRepository support local JSON fallback and backend API mode. If backend is unavailable, load local assets automatically.
```

### Step 7 - Add CWASA WebView

Ask Codex:

```text
Implement CwasaAvatarWidget using flutter_inappwebview. Load assets/cwasa/signbook_avatar.html. Add a Dart method playSigml(String sigml) that calls JavaScript in the WebView. Keep a placeholder fallback if loading fails.
```

### Step 8 - Add OCR and STT Later

Ask Codex:

```text
Add ScanScreen using camera and google_mlkit_text_recognition. After OCR, send the recognized text to Samia reading flow.
```

---

## 20. Demo Script

### Blind Mode Demo

1. Open app.
2. Choose blind mode.
3. Samia welcomes the user by voice.
4. User says or types: "Read Al-Ayyam".
5. App opens the reading screen.
6. Samia reads a page.
7. User says or taps "next page".
8. App continues reading and saves progress.
9. Optional: scan a printed page and let Samia read it.

### Deaf Mode Demo

1. Open app.
2. Choose deaf mode.
3. Visual book grid appears.
4. User selects a book.
5. SignBook reader opens.
6. Avatar area signs the sentence or shows placeholder animation.
7. Current sentence is highlighted.
8. User taps next.
9. Haptic feedback confirms the action.

### Explore Mode Demo

1. Open app.
2. Choose explore mode.
3. Show both accessibility experiences.
4. Explain that the same book content is adapted to two different disability contexts.

---

## 21. Hackathon Acceptance Checklist

### Flutter

- [ ] App launches without crash.
- [ ] Onboarding works.
- [ ] Profile selection persists in Hive.
- [ ] Deaf home shows books.
- [ ] Blind mode opens Samia screen.
- [ ] Reading screen displays book content.
- [ ] TTS reads at least one page.
- [ ] Next/previous page works.
- [ ] Reading progress is saved.
- [ ] SignBook reader opens.
- [ ] Avatar placeholder or CWASA WebView is visible.
- [ ] Haptic feedback works in deaf mode.
- [ ] Offline sample books work without backend.

### Backend

- [ ] `/health` returns OK.
- [ ] `/api/books` returns list of books.
- [ ] `/api/books/{book_id}/content?page=1` returns content.
- [ ] CORS works with Flutter app.
- [ ] Docker compose starts API and database.

### Data

- [ ] At least 6 books or excerpts are included for demo.
- [ ] Arabic and French content are present.
- [ ] Moroccan cultural content is present.
- [ ] No Lorem Ipsum.
- [ ] Public-domain or authorized content only.

### Presentation

- [ ] Demo works offline with fallback data.
- [ ] Judges can understand the disability impact in less than 1 minute.
- [ ] The app shows clear difference between blind mode and deaf mode.
- [ ] The architecture is explainable: Flutter + FastAPI + DB + AI services.

---

## 22. Important Technical Simplifications

For hackathon speed, use these simplifications first:

1. Use local JSON books before PostgreSQL.
2. Use `flutter_tts` before Edge TTS.
3. Use text input before real STT.
4. Use avatar placeholder before full CWASA if needed.
5. Use static gloss mapping before full AI text-to-gloss.
6. Use local search before RAG.
7. Add backend only after mobile demo is stable.

The final demo should look complete, even if some internals are simplified.

---

## 23. Future Improvements

After the hackathon:

- Real Moroccan Sign Language dataset expansion.
- Better Arabic/Darija text normalization.
- Better sign-language grammar, not just word-by-word glossing.
- Full RAG over books with multilingual embeddings.
- User accounts and cloud sync.
- Downloadable offline book packs.
- Accessibility testing with real blind and deaf users.
- Admin dashboard for uploading books and glosses.
- Analytics for reading progress and popular books.

---

## 24. Definition of Done for First Working Version

A first working version is complete when:

1. The Flutter app launches.
2. The user chooses a profile.
3. Deaf user can open a book visually.
4. Blind user can listen to a book page.
5. Book data loads from local assets.
6. The app does not require internet for the basic demo.
7. Backend `/health` works separately.
8. The project is clean enough for Codex to continue implementing new modules.

