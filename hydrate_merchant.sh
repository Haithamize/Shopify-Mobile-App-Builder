#!/bin/bash

set -euo pipefail

#############################################
# hydrate_merchant.sh
#
# Goal:
#  - Transform the Flutter repo into a dedicated merchant build by
#    swapping identifiers + assets (Firebase config, icons, app name).
#
# Inputs:
#  1) MERCHANT_ID   -> selects vault folder merchant_vault/<MERCHANT_ID>
#  2) PACKAGE_NAME  -> Android applicationId + iOS bundle id replacement target
#  3) APP_NAME      -> Android strings.xml + iOS plist display name
#
# What this script DOES:
#  - Android: updates applicationId (build.gradle.kts), app_name (strings.xml),
#    copies google-services.json, copies notification icons, generates launcher icons.
#  - iOS: copies GoogleService-Info.plist, updates Info.plist display names,
#    attempts bundle id replacement in project.pbxproj (best-effort).
#
# What it does NOT do:
#  - signing (keystore / provisioning profiles)
#  - uploading to stores
#
#############################################

ts() { date +"%Y-%m-%d %H:%M:%S"; }
log() { echo "[$(ts)] $*"; }
ok()  { echo "[$(ts)] ✅ $*"; }
warn(){ echo "[$(ts)] ⚠️ $*"; }
die() { echo "[$(ts)] ❌ $*"; exit 1; }

on_error() {
  local exit_code=$?
  echo "[$(ts)] ❌ Script failed (exit=$exit_code) at line $1: $2"
  exit $exit_code
}
trap 'on_error $LINENO "$BASH_COMMAND"' ERR


# Usage: ./hydrate_merchant.sh <MERCHANT_ID> <PACKAGE_NAME> <APP_NAME>
MERCHANT_ID=$1
PACKAGE_NAME=$2
APP_NAME=$3

if [ -z "$MERCHANT_ID" ] || [ -z "$PACKAGE_NAME" ] || [ -z "$APP_NAME" ]; then
  log "❌ Usage: ./hydrate_merchant.sh <MERCHANT_ID> <PACKAGE_NAME> <APP_NAME>"
  exit 1
fi

if [[ "$PACKAGE_NAME" =~ [A-Z] ]]; then
  log "❌ PACKAGE_NAME must be lowercase (Android/Play Store requirement). Got: $PACKAGE_NAME"
  exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"
VAULT_DIR="$PROJECT_ROOT/merchant_vault/$MERCHANT_ID"

log "🚀 Hydrating App for Merchant: $MERCHANT_ID"
log "📁 Project Root: $PROJECT_ROOT"

# Function to handle sed cross-platform (macOS vs Linux)
run_sed() {
    local pattern="$1"
    local file="$2"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$pattern" "$file"
    else
        sed -i "$pattern" "$file"
    fi
}

# --- STEP 1: ANDROID NATIVE UPDATES ---
log "🆔 Updating Android ApplicationId & Namespace..."

ANDROID_APP_GRADLE="$PROJECT_ROOT/android/app/build.gradle.kts"
ANDROID_MANIFEST="$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml"
ANDROID_STRINGS_DIR="$PROJECT_ROOT/android/app/src/main/res/values"

# Stable MainActivity package (do NOT change per merchant)
STABLE_MAIN_PACKAGE="com.shopifyme"
STABLE_MAIN_PATH="$PROJECT_ROOT/android/app/src/main/kotlin/com/shopifyme/MainActivity.kt"

# Check if files exist
if [ ! -f "$ANDROID_APP_GRADLE" ]; then
    log "❌ Error: $ANDROID_APP_GRADLE not found!"
    exit 1
fi

if [ ! -f "$ANDROID_MANIFEST" ]; then
    log "❌ Error: $ANDROID_MANIFEST not found!"
    exit 1
fi

# Get current package name before changing it
OLD_PACKAGE=$(grep -o 'applicationId = "[^"]*"' "$ANDROID_APP_GRADLE" | head -1 | sed 's/applicationId = "//' | sed 's/"//')
log "   Current package: $OLD_PACKAGE → New package: $PACKAGE_NAME"

# 1. Update namespace (Kotlin DSL syntax)
#log "   Updating namespace in build.gradle..."
#run_sed "s/namespace *= *\".*\"/namespace = \"$PACKAGE_NAME\"/" "$ANDROID_APP_GRADLE"

# 2. Update applicationId (Kotlin DSL syntax)
echo "   Updating applicationId in build.gradle..."
run_sed "s/applicationId *= *\".*\"/applicationId = \"$PACKAGE_NAME\"/" "$ANDROID_APP_GRADLE"

# --- CRITICAL FIX: UPDATE MAINACTIVITY PACKAGE ---
#echo "🔧 Fixing MainActivity package reference..."
#MAIN_ACTIVITY_DIR="$PROJECT_ROOT/android/app/src/main/kotlin"
#
## Find MainActivity.kt file
#MAIN_ACTIVITY_FILE=$(find "$MAIN_ACTIVITY_DIR" -name "MainActivity.kt" 2>/dev/null | head -1)
#
#if [ -f "$MAIN_ACTIVITY_FILE" ]; then
#    echo "   Found MainActivity at: $MAIN_ACTIVITY_FILE"
#
#    # Update package declaration in MainActivity.kt
#    if grep -q "package $OLD_PACKAGE" "$MAIN_ACTIVITY_FILE"; then
#        echo "   Updating package from $OLD_PACKAGE to $PACKAGE_NAME"
#        run_sed "s/package $OLD_PACKAGE/package $PACKAGE_NAME/" "$MAIN_ACTIVITY_FILE"
#    else
#        echo "   Current package not found in MainActivity, updating any package declaration"
#        run_sed "s/package .*/package $PACKAGE_NAME/" "$MAIN_ACTIVITY_FILE"
#    fi
#
#    # Check if we need to move the file to new package directory
#    OLD_PACKAGE_PATH=$(echo "$OLD_PACKAGE" | tr '.' '/')
#    NEW_PACKAGE_PATH=$(echo "$PACKAGE_NAME" | tr '.' '/')
#
#    OLD_FULL_PATH="$MAIN_ACTIVITY_DIR/$OLD_PACKAGE_PATH/MainActivity.kt"
#    NEW_FULL_PATH="$MAIN_ACTIVITY_DIR/$NEW_PACKAGE_PATH/MainActivity.kt"
#
#    if [ "$MAIN_ACTIVITY_FILE" = "$OLD_FULL_PATH" ] && [ "$OLD_PACKAGE" != "$PACKAGE_NAME" ]; then
#        echo "   Moving MainActivity to new package directory..."
#        mkdir -p "$(dirname "$NEW_FULL_PATH")"
#        mv "$MAIN_ACTIVITY_FILE" "$NEW_FULL_PATH"
#        echo "   Moved to: $NEW_FULL_PATH"
#
#        # Remove old directory if empty
#        rmdir "$(dirname "$OLD_FULL_PATH")" 2>/dev/null || true
#    fi
#else
#    echo "   ⚠️ MainActivity.kt not found, creating new one..."
#    # Create MainActivity in the new package directory
#    NEW_PACKAGE_PATH=$(echo "$PACKAGE_NAME" | tr '.' '/')
#    NEW_FULL_PATH="$MAIN_ACTIVITY_DIR/$NEW_PACKAGE_PATH/MainActivity.kt"
#
#    mkdir -p "$(dirname "$NEW_FULL_PATH")"
#
#    cat > "$NEW_FULL_PATH" << EOF
#package $PACKAGE_NAME
#
#import io.flutter.embedding.android.FlutterActivity
#
#class MainActivity: FlutterActivity() {
#}
#EOF
#    echo "   Created MainActivity at: $NEW_FULL_PATH"
#fi

# --- STABLE MAINACTIVITY (WHITE-LABEL BUILDER) ---
echo "🔒 Ensuring stable MainActivity exists at: $STABLE_MAIN_PATH"

mkdir -p "$(dirname "$STABLE_MAIN_PATH")"

if [ ! -f "$STABLE_MAIN_PATH" ]; then
  cat > "$STABLE_MAIN_PATH" << EOF
package $STABLE_MAIN_PACKAGE

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
EOF
  echo "   ✅ Created stable MainActivity."
else
  # Ensure package declaration is correct (in case it was edited)
  if ! grep -q "^package $STABLE_MAIN_PACKAGE" "$STABLE_MAIN_PATH"; then
    echo "   ⚠️ MainActivity package was changed. Resetting to $STABLE_MAIN_PACKAGE"
    run_sed "s/^package .*/package $STABLE_MAIN_PACKAGE/" "$STABLE_MAIN_PATH"
  fi

  # Ensure FlutterActivity import exists
  if ! grep -q "^import io\.flutter\.embedding\.android\.FlutterActivity" "$STABLE_MAIN_PATH"; then
    echo "   ⚠️ MainActivity missing FlutterActivity import. Adding it."
    # Insert import after package line
    awk 'NR==1{print $0 "\n\nimport io.flutter.embedding.android.FlutterActivity"; next}1' "$STABLE_MAIN_PATH" > "$STABLE_MAIN_PATH.tmp" && mv "$STABLE_MAIN_PATH.tmp" "$STABLE_MAIN_PATH"
  fi

  echo "   ✅ Stable MainActivity exists."
fi

# --- STEP 2: IOS BUNDLE ID ---
echo "🍎 Updating iOS Bundle Identifier..."
IOS_PROJECT="$PROJECT_ROOT/ios/Runner.xcodeproj/project.pbxproj"

if [ -f "$IOS_PROJECT" ]; then
    echo "   Updating bundle ID in iOS project..."

    if grep -q "$OLD_PACKAGE" "$IOS_PROJECT"; then
      run_sed "s/$OLD_PACKAGE/$PACKAGE_NAME/g" "$IOS_PROJECT"
    else
      echo "   ⚠️ Old bundle/package '$OLD_PACKAGE' not found in pbxproj. Skipping replace to avoid corruption."
      echo "   (You may need a more targeted pbxproj update if this is the first run.)"
    fi
else
    echo "   ⚠️ iOS project file not found, skipping iOS updates"
fi

# --- STEP 3: APP NAME & STRINGS ---
echo "🏷️ Setting Display Name to: $APP_NAME"

# Create strings directory if it doesn't exist
mkdir -p "$ANDROID_STRINGS_DIR"

# Update or create strings.xml
ANDROID_STRINGS_FILE="$ANDROID_STRINGS_DIR/strings.xml"
if [ -f "$ANDROID_STRINGS_FILE" ]; then
    # Update existing strings.xml
    echo "   Updating existing strings.xml..."
    if grep -q "<string name=\"app_name\">" "$ANDROID_STRINGS_FILE"; then
        # Update existing app_name string
        run_sed "s/<string name=\"app_name\">.*<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/" "$ANDROID_STRINGS_FILE"
    else
        # Add app_name string if it doesn't exist
        echo "    <string name=\"app_name\">$APP_NAME</string>" >> "$ANDROID_STRINGS_FILE"
    fi
else
    # Create new strings.xml
    echo "   Creating new strings.xml..."
    cat > "$ANDROID_STRINGS_FILE" << EOF
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$APP_NAME</string>
</resources>
EOF
fi

# Update iOS app name
IOS_INFO_PLIST="$PROJECT_ROOT/ios/Runner/Info.plist"
if [[ "$OSTYPE" == "darwin"* ]] && [ -f "$IOS_INFO_PLIST" ]; then
    echo "   Updating iOS app name..."
    plutil -replace CFBundleDisplayName -string "$APP_NAME" "$IOS_INFO_PLIST"
    plutil -replace CFBundleName -string "$APP_NAME" "$IOS_INFO_PLIST"
fi

# --- STEP 4: FIREBASE CONFIG SWAP ---
echo "📂 Injecting Firebase Configs..."

# Check if vault directory exists
if [ ! -d "$VAULT_DIR" ]; then
    echo "❌ Error: Vault directory $VAULT_DIR not found!"
    exit 1
fi

# Android Firebase config
ANDROID_FIREBASE="$VAULT_DIR/google-services.json"

if [ ! -f "$ANDROID_FIREBASE" ]; then
    echo "❌ Android Firebase config not found: $ANDROID_FIREBASE"
    echo "   Put google-services.json under: merchant_vault/<MERCHANT_ID>/google-services.json"
    exit 1
fi

# Non-empty check
if [ ! -s "$ANDROID_FIREBASE" ]; then
    echo "❌ Android Firebase config is EMPTY: $ANDROID_FIREBASE"
    echo "   Create a Firebase project + Android app for package: $PACKAGE_NAME"
    echo "   Then download google-services.json and place it in the vault."
    exit 1
fi

# Valid JSON check
python3 -m json.tool "$ANDROID_FIREBASE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Malformed JSON in: $ANDROID_FIREBASE"
    echo "   Re-download google-services.json from Firebase Console for package: $PACKAGE_NAME"
    exit 1
fi

if ! grep -q "\"package_name\" *: *\"$PACKAGE_NAME\"" "$ANDROID_FIREBASE"; then
  echo "❌ google-services.json does NOT contain package_name=$PACKAGE_NAME"
  echo "   Download the config for the correct Android app from Firebase Console."
  exit 1
fi

echo "   Copying Android Firebase config..."
cp "$ANDROID_FIREBASE" "$PROJECT_ROOT/android/app/google-services.json"

# iOS Firebase config
IOS_FIREBASE="$VAULT_DIR/GoogleService-Info.plist"
if [ -f "$IOS_FIREBASE" ]; then
    echo "   Copying iOS Firebase config..."
    cp "$IOS_FIREBASE" "$PROJECT_ROOT/ios/Runner/GoogleService-Info.plist"
else
    echo "❌ Missing iOS Firebase config: $IOS_FIREBASE"
    echo "   Put GoogleService-Info.plist under: merchant_vault/<MERCHANT_ID>/GoogleService-Info.plist"
    exit 1
fi

# --- STEP 5: APP ICON GENERATION ---
echo "🎨 Generating App Icons..."
ICON_FILE="$VAULT_DIR/icon.png"

if [ -f "$ICON_FILE" ]; then
    echo "   Copying icon file..."
    cp "$ICON_FILE" "$PROJECT_ROOT/assets/icon_temp.png"

    # --- ANDROID NOTIFICATION ICONS (PER MERCHANT) ---
    # Android uses:
    # - Small icon (status bar) -> MUST be white/transparent: @drawable/ic_stat_notification
    # - Large icon (inside notification) -> can be colored: @drawable/notification_large
    DRAWABLE_DIR="$PROJECT_ROOT/android/app/src/main/res/drawable"
    mkdir -p "$DRAWABLE_DIR"

    # 1) Small notification icon (REQUIRED per merchant - fail if missing)
    VAULT_SMALL_ICON="$VAULT_DIR/ic_stat_notification.png"
    SMALL_ICON_DEST="$DRAWABLE_DIR/ic_stat_notification.png"

    if [ -f "$VAULT_SMALL_ICON" ] && [ -s "$VAULT_SMALL_ICON" ]; then
      echo "   Copying merchant small notification icon..."
      cp "$VAULT_SMALL_ICON" "$SMALL_ICON_DEST"
      echo "   ✅ Small notification icon copied to: $SMALL_ICON_DEST"
    else
      echo "❌ Missing merchant small notification icon: $VAULT_SMALL_ICON"
      echo "   Provide a WHITE/TRANSPARENT PNG named ic_stat_notification.png in the vault."
      exit 1
    fi

    # 2) Large notification icon (colored) - use merchant icon.png
    LARGE_ICON_DEST="$DRAWABLE_DIR/notification_large.png"
    cp "$ICON_FILE" "$LARGE_ICON_DEST"
    echo "   ✅ Large notification icon copied to: $LARGE_ICON_DEST"

    # Create flutter_launcher_icons config
    cat <<EOF > "$PROJECT_ROOT/flutter_launcher_icons.yaml"
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon_temp.png"
  min_sdk_android: 21
  remove_alpha_ios: true
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "assets/icon_temp.png"
EOF

    echo "   Generating launcher icons..."
    cd "$PROJECT_ROOT"
    dart run flutter_launcher_icons:main -f flutter_launcher_icons.yaml

    # Cleanup
    rm "$PROJECT_ROOT/flutter_launcher_icons.yaml"
    rm "$PROJECT_ROOT/assets/icon_temp.png"
else
    echo "   ⚠️ Icon file not found in $VAULT_DIR, skipping icon generation"
fi

# --- CLEAN AND REBUILD ---
echo "🧹 Cleaning and rebuilding..."
cd "$PROJECT_ROOT"
flutter clean > /dev/null 2>&1
cd "$PROJECT_ROOT/android"
./gradlew clean > /dev/null 2>&1
cd "$PROJECT_ROOT"
flutter pub get > /dev/null 2>&1

# --- VERIFICATION ---
echo "✅ Hydration Complete!"
echo ""
echo "📋 VERIFICATION CHECKLIST:"
echo "=========================="
echo "1. Android Package Name:"
grep -E "applicationId|namespace" "$ANDROID_APP_GRADLE" || echo "   ❌ Not found in build.gradle"
echo ""
echo "2. Android Identifiers (source of truth):"
grep -E "namespace *=|applicationId *=" "$ANDROID_APP_GRADLE" || echo "   ❌ Not found in build.gradle.kts"
echo ""
echo "3. MainActivity Location (stable):"
if [ -f "$STABLE_MAIN_PATH" ]; then
    echo "   ✅ Found at: $STABLE_MAIN_PATH"
    echo "   Package in MainActivity: $(grep '^package' "$STABLE_MAIN_PATH" 2>/dev/null || echo "Not found")"
else
    echo "   ❌ Stable MainActivity not found at: $STABLE_MAIN_PATH"
fi
echo ""
echo "4. Android App Name:"
if [ -f "$ANDROID_STRINGS_FILE" ]; then
    grep "app_name" "$ANDROID_STRINGS_FILE" || echo "   ❌ Not found in strings.xml"
else
    echo "   ❌ strings.xml not found"
fi
echo ""
echo "5. File Existence Check:"
if [ -f "$PROJECT_ROOT/android/app/google-services.json" ]; then
    echo "   ✅ google-services.json exists"
else
    echo "   ⚠️ google-services.json not found"
fi
echo ""
echo "6. Android Notification Icons:"
if [ -f "$PROJECT_ROOT/android/app/src/main/res/drawable/ic_stat_notification.png" ]; then
    echo "   ✅ ic_stat_notification.png exists"
else
    echo "   ❌ ic_stat_notification.png missing"
fi
if [ -f "$PROJECT_ROOT/android/app/src/main/res/drawable/notification_large.png" ]; then
    echo "   ✅ notification_large.png exists"
else
    echo "   ❌ notification_large.png missing"
fi
echo ""
echo "7. iOS Bundle ID (if iOS exists):"
if [ -f "$IOS_PROJECT" ]; then
    grep -n "$PACKAGE_NAME" "$IOS_PROJECT" | head -5 || echo "   ❌ Package name not found in iOS project"
fi

# Create a verification report
VERIFICATION_FILE="$PROJECT_ROOT/hydration_verification.txt"
cat > "$VERIFICATION_FILE" << EOF
Hydration Verification Report
=============================
Merchant ID: $MERCHANT_ID
Package Name: $PACKAGE_NAME
App Name: $APP_NAME
Timestamp: $(date)

Android Files Modified:
- build.gradle: $(grep -q "$PACKAGE_NAME" "$ANDROID_APP_GRADLE" && echo "✅ Updated" || echo "❌ Not updated")
- Android namespace: $(grep -q "namespace = \"$PACKAGE_NAME\"" "$ANDROID_APP_GRADLE" && echo "✅ Updated" || echo "❌ Not updated")
- Android applicationId: $(grep -q "applicationId = \"$PACKAGE_NAME\"" "$ANDROID_APP_GRADLE" && echo "✅ Updated" || echo "❌ Not updated")
- MainActivity (stable): $(if [ -f "$STABLE_MAIN_PATH" ]; then echo "✅ Present"; else echo "❌ Missing"; fi)
- strings.xml: $(grep -q ">$APP_NAME<" "$ANDROID_STRINGS_FILE" 2>/dev/null && echo "✅ Updated" || echo "❌ Not updated")

Android Notification Icons:
- Small: $(if [ -f "$PROJECT_ROOT/android/app/src/main/res/drawable/ic_stat_notification.png" ]; then echo "✅ Present"; else echo "❌ Missing"; fi)
- Large: $(if [ -f "$PROJECT_ROOT/android/app/src/main/res/drawable/notification_large.png" ]; then echo "✅ Present"; else echo "❌ Missing"; fi)

iOS Files Modified:
- Project.pbxproj: $(if [ -f "$IOS_PROJECT" ]; then grep -q "$PACKAGE_NAME" "$IOS_PROJECT" && echo "✅ Updated" || echo "❌ Not updated"; else echo "⚠️ Not found"; fi)

Files Copied:
- google-services.json: $(if [ -f "$PROJECT_ROOT/android/app/google-services.json" ]; then echo "✅ Copied"; else echo "❌ Missing"; fi)
- GoogleService-Info.plist: $(if [ -f "$PROJECT_ROOT/ios/Runner/GoogleService-Info.plist" ]; then echo "✅ Copied"; else echo "❌ Missing"; fi)

Run the following commands to verify:
- Android: adb shell pm list packages | grep $PACKAGE_NAME
- Build test: flutter build apk --debug
EOF

echo ""
echo "📄 Detailed verification report saved to: $VERIFICATION_FILE"
echo ""
echo "🔧 To test the build:"
echo "flutter build apk --debug"
echo "# The APK will be at: build/app/outputs/flutter-apk/app-debug.apk"
