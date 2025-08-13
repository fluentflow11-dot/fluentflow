# FluentFlow – Project Context (for new chats)

## What we’re building
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
- Top-level tasks: IDs 21–30 generated from PRD (21 = setup → 30 = settings/compliance)
- Completed:
  - 21.1 Create Flutter project
  - 21.2 Configure deps/state management (Riverpod, go_router, Hive, Firebase packages)
  - 21.3 Set up Material 3 theming and design tokens (design tokens + preview wired)
  - 21.4 Firebase project/app config; Firestore write/read verified on-device
  - 21.5 Integrate Firebase Core and Authentication (Email/Password + Anonymous)
  - 21.6 Integrate Firestore and Storage
  - 21.7 Integrate remaining Firebase services (Remote Config, Crashlytics, App Check)
  - 21.8 Hive initialization and cache smoke test
  - 21.9 Configure environment variables and secrets management
- In progress: 21 (parent)
 - Next task to do: 21.12 Create comprehensive documentation

Quick commands
```bash
# List + next
npx -y task-master list --with-subtasks
npx -y task-master next

# Mark status
npx -y task-master set-status --id=21 --status=in-progress
npx -y task-master set-status --id=21.2 --status=done

# Helpful for current focus (21.5)
# Helpful for current focus (21.12)
npx -y task-master show 21.12
npx -y task-master set-status --id=21.12 --status=in-progress
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
- First launch logs may show “Skipped frames” and ion driver messages; acceptable in debug.

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
- Don’t chain commands with `&&`; run them one-by-one in this PS version.
- If relative paths fail, use the absolute Flutter path shown above.

## What is already wired
- Riverpod: main.dart uses ProviderScope; app entry in lib/app.dart
- Routing: lib/core/router.dart with go_router → HomeScreen at '/'
- Themes: Material 3 with design tokens in `lib/core/theme.dart`; preview on HomeScreen
- Hive: initialized via `initializeHive()`, boxes `app_prefs` and `cache` opened at startup
- Firebase: Android app registered; `google-services.json` present; initialization works via default resources; Firestore verified

## PRD highlights
- Flows: Onboarding, Home/Daily Lessons, Conversation, Pronunciation, Grammar Tiles, Practice, League, Account/Settings/Achievements
- Premium vs Free; UI Component Inventory; Layout Blueprints
- IP Compliance & Differentiation policy

## Environment/API keys
- CLI (Taskmaster): create `.env` at repo root (git-ignored) and add the provider keys you use (e.g., `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `PERPLEXITY_API_KEY`).
- MCP (Cursor): set the same keys in `.cursor/mcp.json` under `env`.
- Firebase App Check API: enable it in Google Cloud for this project to remove debug App Check warnings.

## Known/pending
- Documentation (21.12): consolidate run instructions, debugging tips, architecture overview
- Caching strategy expansion (content/offline) later in tasks 27.x

## How to continue (new chat)
1) Open this file for context.
2) Run `npx -y task-master next` to confirm the next actionable item.
3) Implement 21.12 (documentation): add architecture/flows, run/debug instructions, and contribution guide.
4) Keep analyzer/build green; run on device from `mobile_app`.

## Collaboration mode (owner is a novice)
- The project owner is a complete novice and wants Cursor to drive as much of the project as possible end-to-end (coding, wiring, debugging, running commands).
- Prefer automated edits and terminal commands over manual instructions.
- When choices arise, pick sensible defaults and proceed without waiting, unless credentials or console clicks are strictly needed.
- Always run Flutter commands from `mobile_app`; use absolute SDK path: `C:\Users\USER1\fluentflow\.flutter-sdk\bin\flutter.bat`.
