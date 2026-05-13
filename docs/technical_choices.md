# Technical Choices

- **Offline-first mobile MVP:** Local JSON assets keep the demo reliable without network access.
- **Flutter source scaffold:** The source app is ready under `mobile/`; platform folders can be generated with Flutter once the SDK is installed.
- **Primitive Hive boxes:** Profile and reading progress use simple maps instead of generated adapters to avoid build-runner overhead.
- **Native TTS first:** `flutter_tts` gives a real blind-mode demo before adding backend audio synthesis.
- **Static gloss mapping first:** SignBook uses deterministic local mappings before AI text-to-gloss or full CWASA integration.
- **FastAPI sample backend:** The API reads the same sample JSON as the Flutter app so mobile and backend data stay aligned.
