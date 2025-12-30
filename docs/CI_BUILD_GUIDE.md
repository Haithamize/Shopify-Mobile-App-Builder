# CI Build Guide (Hydration + Build Only)

## What we’re testing in CI
We test two build types:

### 1) Demo app (Free plan)
- Single published app in your consoles (later)
- In CI we still run hydration using a "demo_default" vault to ensure Firebase + icons exist.

### 2) Dedicated app (Paid plan)
- Per-merchant identifiers + Firebase configs + icons

## Merchant Vault Structure
Create:
merchant_vault/<MERCHANT_ID>/
google-services.json
GoogleService-Info.plist
icon.png
ic_stat_notification.png

Example:
merchant_vault/merchant_demo/google-services.json
merchant_vault/merchant_demo/GoogleService-Info.plist
merchant_vault/merchant_demo/icon.png
merchant_vault/merchant_demo/ic_stat_notification.png

## What hydration does
- Android:
    - Updates applicationId in android/app/build.gradle.kts
    - Updates app_name in android/app/src/main/res/values/strings.xml
    - Copies merchant google-services.json into android/app/google-services.json
    - Copies notification icons into android/app/src/main/res/drawable/
    - Generates launcher icons using flutter_launcher_icons
- iOS:
    - Copies GoogleService-Info.plist into ios/Runner/
    - Updates CFBundleDisplayName / CFBundleName in ios/Runner/Info.plist
    - Attempts bundle id update in ios/Runner.xcodeproj/project.pbxproj (best-effort)

## What CI produces
- Android: app-debug.apk (installable on Android devices)
- iOS: Runner.app (simulator build) zipped as Runner-simulator.app.zip (NOT installable on iPhones without signing)

## Why iOS is not installable yet
An installable iPhone IPA requires Apple code signing (TestFlight or Ad Hoc).
We intentionally skip signing in this PoC.
