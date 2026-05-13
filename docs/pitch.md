# KitabLilJamie Pitch

## One-Minute Story

Books are still not equally reachable. A blind reader may need someone to read aloud. A deaf reader may get text, but not a sign-friendly explanation. KitabLilJamie turns the same library into two accessible experiences: **Samia**, a voice-first assistant that reads books aloud, and **SignBook**, a visual reader that prepares text for signing.

## Demo Flow

1. Open the app and choose **Blind mode - Samia**.
2. Type or say a book title, then open the reader.
3. Tap **Start reading** and hear the page through TTS.
4. Go back, choose **Deaf mode - SignBook**, and open the same library.
5. Show the visual reader, animated avatar placeholder, gloss chips, and next-page haptic feedback.

## What Is Real Today

- Offline book library from local JSON.
- Accessible Flutter UI structure with large controls.
- TTS reading flow for blind and visually impaired users.
- Visual SignBook flow with static gloss mapping and avatar placeholder.
- Reading progress saved locally with Hive.
- FastAPI backend with health, books, page content, and text-to-gloss endpoints.

## Why It Can Grow

The architecture separates UI, repositories, services, and backend endpoints. That makes the demo small enough for a hackathon, but ready for later STT, OCR, CWASA/SiGML playback, PostgreSQL, and RAG over public-domain books.
