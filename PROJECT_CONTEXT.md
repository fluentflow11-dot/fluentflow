# FluentFlow – Project Context (for new chats)

## What we're building
- Loora AI–inspired English learning app
- Tech: Flutter (stable), Firebase (Auth, Firestore, Storage, Remote Config, Messaging, Analytics, Crashlytics, App Check), Riverpod, go_router, Hive
- Platform: Android first (Play Store), web/windows dev targets available

## Current repo layout (important paths)
- mobile_app/ – Flutter app
- .flutter-sdk/ – local Flutter SDK (cloned stable channel)
- .taskmaster/docs/prd.txt – comprehensive PRD (flows, UI spec, premium/free, compliance)
- .taskmaster/docs/transcripts/ – transcripts auto-extracted from videos
- research/loora/ – reference screenshots/videos and generated stills
- scripts/process-assets.mjs – ffmpeg + Whisper transcription helper
- .cursor/rules/ – UI rules for professional design in Cursor

## Task Master status
- Top-level tasks: IDs 21–30 generated from PRD
- Completed (21 Setup):
  - 21.1–21.12 all done (project created, theming, Firebase, Hive, error handling, CI, docs)
- Epic 22 – Authentication: COMPLETE (except iOS Apple)
  - Done: 22.1 (Firebase Auth setup), 22.2 (Email/Password), 22.3 (Google Sign-In), 22.5 (Profile flow), 22.6 (Session persistence + secure token store), 22.7 (Age gate), 22.8 (Password reset), 22.9 (Firestore rules deployed), 22.10 (Analytics events)
  - Deferred: 22.4 (Apple Sign‑In for iOS)
- Epic 23 – Onboarding Experience: COMPLETE ✅
  - Done: 23.1 (Intro), 23.2 (Wizard scaffold + progress), 23.3 (Account step), 23.4 (Goals + Level steps), 23.5 (Schedule), 23.6 (Permissions – Notifications/Microphone), 23.7 (Language selection), 23.8 (Navigation + state persistence), 23.9 (Validation + Skip), 23.10 (Analytics tracking + final completion)
- Current epic: 24 Home Screen Development
  - Done: 24.1 (Create Home Screen Layout UI Components - baseline UI with welcome header, progress card, categories grid)
  - Next: 24.2 (Implement Daily Lesson Card), 24.3 (Add Progress Tracking), 24.4 (Create Navigation to Other Screens)

Quick commands
```bash
# List + next
npx -y task-master list --with-subtasks
npx -y task-master next

# Mark status for current epic
npx -y task-master set-status --id=24 --status=in-progress
npx -y task-master show 24.2,24.3,24.4
```

## Run instructions (Android device)
```bash
# From repo root
# Verify device
.\.flutter-sdk\bin\flutter.bat devices -v
# Run on physical device (replace with detected ID)
cd mobile_app
..\.flutter-sdk\bin\flutter.bat run -d FUBYIJMJX86DJNPZ
```
Notes
- Android config pinned for Firebase:
  - mobile_app/android/app/build.gradle.kts → minSdk = 23, ndkVersion = 27.0.12077973
- First launch logs may show "Skipped frames" and ion driver messages; acceptable in debug.
- Windows: Developer Mode should be ON (enables symlinks for Flutter plugins).

## Single-terminal workflow (Windows PowerShell)

Use a single PowerShell window so you see full logs and can hot-reload.

```powershell
# Go to the app folder
Set-Location C:\Users\USER1\fluentflow\mobile_app
# List devices
C:\Users\USER1\fluentflow\.flutter-sdk\bin\flutter.bat devices -v
# Run with logs (replace device ID if needed)
C:\Users\USER1\fluentflow\.flutter-sdk\bin\flutter.bat run -d FUBYIJMJX86DJNPZ --debug
# Hotkeys: r (reload) | R (restart) | q (quit)
```

Tips
- Don't chain commands with `&&`; run them one-by-one in this PS version.
- If relative paths fail, use the absolute Flutter path shown above.

## What is already wired
- Riverpod: main.dart uses ProviderScope; app entry in lib/app.dart
- Routing: lib/core/router.dart with go_router → HomeScreen at '/'
- Themes: Material 3 with design tokens in `lib/core/theme.dart`; preview on HomeScreen
- Hive: initialized via `initializeHive()`, boxes `app_prefs` and `cache` opened at startup
- Firebase: Android app registered; `google-services.json` present; initialization works via default resources; Firestore verified
- Firestore rules: locked down; `users/{uid}/**` only accessible to the authenticated `uid`; `debug/**` only for authed users
- Auth session persistence: secure token storage with `flutter_secure_storage`, automatic refresh
- Age gate: `/age-gate` screen + enforced redirects
- Onboarding: intro + multi-step wizard (Account, Goals, Level, Schedule, Permissions, Language) with full persistence and analytics
- Onboarding persistence: selections saved in Hive; final completion toggles `onboard_complete=true`
- Onboarding analytics: step views, durations, skips, completion events tracked
- Home Screen: baseline UI with welcome header, progress card, categories grid (Daily Lesson, Conversation, etc.)
- Debug tools on Home: Reset age gate, Open onboarding intro, Reset onboarding, Firestore read/write test
- Theme swatches on Home: interactive seed color selection persisted in Hive
- Permissions: Notifications (Firebase Messaging) and Microphone (permission_handler) with runtime requests

## PRD highlights
- Flows: Onboarding, Home/Daily Lessons, Conversation, Pronunciation, Grammar Tiles, Practice, League, Account/Settings/Achievements
- Premium vs Free; UI Component Inventory; Layout Blueprints
- IP Compliance & Differentiation policy

## Environment/API keys
- CLI (Taskmaster): create `.env` at repo root (git-ignored) and add the provider keys you use (e.g., `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `PERPLEXITY_API_KEY`).
- MCP (Cursor): set the same keys in `.cursor/mcp.json` under `env`.
- Firebase App Check API: enable it in Google Cloud for this project to remove debug App Check warnings.

## Known/pending
- iOS Apple Sign‑In (22.4) – deferred
- Home Screen: 24.2 (Daily Lesson Card), 24.3 (Progress Tracking), 24.4 (Navigation to Other Screens)
- Documentation (21.12): consolidate run instructions, debugging tips, architecture overview
- Caching strategy expansion (content/offline) later in tasks 27.x

## How to continue (new chat)
1) Open this file for context.
2) Run `npx -y task-master next` to confirm the next actionable item (should surface 24.2/24.3/24.4).
3) Proceed to complete Home Screen development (24.2 → 24.3 → 24.4). Then revisit 22.4 (iOS Apple Sign‑In) when targeting iOS.
4) Keep analyzer/build green; run on device from `mobile_app`.

## Collaboration mode (owner is a novice)
- The project owner is a complete novice and wants Cursor to drive as much of the project as possible end-to-end (coding, wiring, debugging, running commands).
- Prefer automated edits and terminal commands over manual instructions.
- When choices arise, pick sensible defaults and proceed without waiting, unless credentials or console clicks are strictly needed.
- Always run Flutter commands from `mobile_app`; use absolute SDK path: `C:\Users\USER1\fluentflow\.flutter-sdk\bin\flutter.bat`.
