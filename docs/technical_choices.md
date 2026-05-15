# Technical Choices

- **Offline-first mobile MVP:** Local JSON assets keep the demo reliable without network access.
- **Flutter source scaffold:** The source app is ready under `mobile/`; platform folders can be generated with Flutter once the SDK is installed.
- **Primitive Hive boxes:** Profile and reading progress use simple maps instead of generated adapters to avoid build-runner overhead.
- **Native TTS first:** `flutter_tts` gives a real blind-mode demo before adding backend audio synthesis.
- **CWASA WebView for SignBook:** The demo loads UEA's unmodified CWASA WebGL runtime in a Flutter WebView and sends generated SiGML text from the local gloss pipeline. The current gestures prove playback and integration; validated Moroccan Sign Language coverage remains future work.
- **Optional FastAPI API mode:** Mobile defaults to local JSON for a reliable offline pitch demo, but can opt into FastAPI with `--dart-define=USE_BACKEND=true`; failed API calls automatically fall back to bundled assets.
