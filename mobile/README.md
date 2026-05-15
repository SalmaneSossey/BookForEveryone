# Mobile App

Flutter source for the KitabLilJamie accessible reading MVP.

## Setup

The WSL toolchain is installed in user space:

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

The generated debug APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

By default the app reads bundled JSON so the demo works offline. To try the
FastAPI backend instead, run with:

```bash
flutter run --dart-define=USE_BACKEND=true --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For a physical Android phone, replace `10.0.2.2` with the development
machine's LAN IP address.

To run on a real Android device from WSL, connect USB debugging through Windows/WSL ADB and confirm the device appears in `flutter devices`, then run `flutter run -d <device-id>`.

## MVP Routes

- `/` onboarding with Blind, Deaf, and Explore choices
- `/samia` voice-first book search and text-command fallback
- `/reading/:bookId` TTS reader with saved progress
- `/home-deaf` visual SignBook library grid
- `/signbook/:bookId` sign-friendly reader with gloss chips and haptic feedback
- `/explore` judge/demo discovery view

## Accessibility Notes

- Main controls use large 56dp minimum button height.
- Book cards and controls include semantic labels for screen readers.
- Blind mode works from text fallback first, then TTS reads pages aloud.
- Deaf mode avoids audio dependency and uses visual gloss state plus haptic feedback.
