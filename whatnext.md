
**Done**
- Flutter Android app scaffolded and builds APK.
- Onboarding: Blind / Deaf / Explore.
- Local books JSON.
- Samia screen + text command fallback.
- TTS reading screen with next/previous/pause/continue.
- Hive profile/progress storage.
- Deaf visual book grid.
- SignBook reader with a large CWASA WebView avatar panel, gloss chips, haptics.
- SignBook demo polish: active chip highlight, mapped/fallback status, Flutter fallback if CWASA fails.
- WebView loads the official unmodified CWASA WebGL runtime from UEA and sends generated SiGML text from Flutter.
- Expanded Arabic/French/Moroccan demo content.
- Expanded Arabic/Darija gloss matching for common forms like prefixes and suffixes.
- Samia reader status now shows ready/reading/paused/stopped/finished feedback.
- FastAPI backend: `/health`, books endpoints, SignBook gloss endpoint.
- Docker backend is running and healthy on port `8000`.
- APK installed and relaunched on Redmi 12.

**Left For Pitch Priority**
1. Finish real-device demo testing.
   - Confirm TTS, haptics, navigation, and Hive persistence on Redmi 12.
   - Also test TalkBack and larger Android font sizes if time allows.

2. Backend connection smoke test.
   - Mobile now has optional API mode with automatic local JSON fallback.
   - Run with `--dart-define=USE_BACKEND=true` and confirm book/page loading against FastAPI.
   - Keep offline mode as the default pitch path.

3. Improve real signing quality.
   - Current: CWASA WebView prototype with generated demo SiGML gestures.
   - Left: add validated Moroccan Sign Language / SiGML signs instead of generic demo gestures.
   - Consider bundling CWASA resources locally if the pitch venue has unreliable internet.

4. Add real STT/OCR later.
   - Current: text command fallback.
   - Left: speech-to-text, camera scan, ML Kit OCR.

5. Add final pitch polish.
   - App icon/name polish.
   - Better first-screen copy.
   - Final run-through of the pitch script with the phone in hand.

**Not Needed For MVP Pitch**
- PostgreSQL
- ChromaDB
- Mistral/RAG
- faster-whisper backend
- Edge TTS endpoint
- Full CWASA/SiGML coverage

So: we are pitch-close. The next smart move is **install the APK on a phone/emulator and fix whatever appears in real-device testing**.
