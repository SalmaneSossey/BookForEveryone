# BookForEveryone / KitabLilJamie

Accessible reading MVP for blind, visually impaired, and deaf readers. The first slice is an offline-first Flutter mobile app with:

- **Samia**: voice-first reading with `flutter_tts`, text-command fallback, page controls, and saved reading progress.
- **SignBook**: visual reading with a signing-avatar placeholder, gloss chips, haptic feedback hooks, and saved reading progress.
- **FastAPI backend**: sample `/health`, books, book-page, and text-to-gloss endpoints.

## Structure

```text
mobile/      Flutter app source and local demo assets
backend/     FastAPI sample backend
docs/        Demo and implementation notes
```

## Mobile

Flutter and the Android toolchain are installed in this WSL environment:

- Flutter: `/home/salmane/development/flutter`
- JDK 17: `/home/salmane/development/jdk-17`
- Android SDK: `/home/salmane/Android/Sdk`

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The app uses `assets/data/sample_books.json` for offline demo content.

See [mobile/README.md](mobile/README.md) for the mobile route map and accessibility notes.

## Backend

```bash
cd backend
make install
make test
make run
```

Then open:

- `GET http://127.0.0.1:8000/health`
- `GET http://127.0.0.1:8000/api/books`
- `GET http://127.0.0.1:8000/api/books/arabic-garden/content?page=1`

Docker Desktop flow:

```bash
docker compose -f backend/docker-compose.yml build
docker compose -f backend/docker-compose.yml up
```

## Pitch

Use [docs/pitch.md](docs/pitch.md) and [docs/demo_script.md](docs/demo_script.md) for the hackathon presentation flow.
