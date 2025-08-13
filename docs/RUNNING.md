# Running FluentFlow

## Prereqs
- Local Flutter SDK in `.flutter-sdk/` (stable)
- Android device connected or Windows desktop enabled
- Firebase project configured (google-services.json present for Android)

## Android (Windows PowerShell)
```powershell
# From repo root
Set-Location C:\Users\USER1\fluentflow

# List devices
.\.flutter-sdk\bin\flutter.bat devices -v

# Run on device (replace ID)
Set-Location mobile_app
..\.flutter-sdk\bin\flutter.bat run -d FUBYIJMJX86DJNPZ --debug
```

## Windows Desktop
```powershell
Set-Location C:\Users\USER1\fluentflow\mobile_app
..\.flutter-sdk\bin\flutter.bat config --enable-windows-desktop
..\.flutter-sdk\bin\flutter.bat run -d windows --debug
```

## Useful
- Hotkeys: r (hot reload), R (restart), q (quit)
- Logs may show ion/BLAST errors in debug; safe to ignore
- Crashlytics: use Home debug buttons to send non-fatal/fatal events

## Tests
```powershell
Set-Location C:\Users\USER1\fluentflow\mobile_app
..\.flutter-sdk\bin\flutter.bat analyze
..\.flutter-sdk\bin\flutter.bat test
```

## CI
- GitHub Actions workflow at `.github/workflows/flutter-ci.yml` runs analyze/test/build on push/PR


