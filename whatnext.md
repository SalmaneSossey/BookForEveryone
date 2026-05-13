**Short answer:** the MVP is mostly built. What’s left is mainly the “wow demo” polish and advanced features from later phases.

**Done**
- Flutter Android app scaffolded and builds APK.
- Onboarding: Blind / Deaf / Explore.
- Local books JSON.
- Samia screen + text command fallback.
- TTS reading screen with next/previous/pause/continue.
- Hive profile/progress storage.
- Deaf visual book grid.
- SignBook reader with avatar placeholder, gloss chips, haptics.
- FastAPI backend: `/health`, books endpoints, SignBook gloss endpoint.
- Docker backend is running and healthy on port `8000`.
- APK exists in Downloads.

**Left For Pitch Priority**
1. Test APK on real Android phone/emulator.
   - This is the biggest remaining thing.
   - We need confirm TTS, haptics, navigation, and Hive persistence on device.

2. Improve demo content.
   - Current sample books are enough for testing.
   - Architecture asks for richer Arabic/French/Moroccan public-domain excerpts.
   - Add more Arabic content especially.

3. Connect mobile to backend optionally.
   - Right now mobile works offline from local JSON.
   - Backend works separately.
   - Architecture Step 6 says add API fallback mode with local fallback.

4. Replace SignBook placeholder with real WebView/CWASA.
   - Current: animated placeholder + gloss chips.
   - Left: `flutter_inappwebview`, load `assets/cwasa/signbook_avatar.html`, call `playSigml`.

5. Add real STT/OCR later.
   - Current: text command fallback.
   - Left: speech-to-text, camera scan, ML Kit OCR.

6. Add pitch polish.
   - App icon/name polish.
   - Better first-screen copy.
   - More obvious “Samia is reading” feedback.
   - Maybe a Moroccan/Darija command examples card.

**Not Needed For MVP Pitch**
- PostgreSQL
- ChromaDB
- Mistral/RAG
- faster-whisper backend
- Edge TTS endpoint
- Full CWASA/SiGML coverage

So: we are pitch-close. The next smart move is **install the APK on a phone/emulator and fix whatever appears in real-device testing**.