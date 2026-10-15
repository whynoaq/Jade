
#!/bin/bash
set -euo pipefail

PROJECT="Jade.xcodeproj"
SCHEME="Jade"
CONFIG="Debug"
BUILD_DIR="build"

if [ -d "/Applications/Xcode-beta.app" ]; then
    export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
elif [ -d "/Applications/Xcode.app" ]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
else
    echo "ERROR: Xcode not found" >&2
    exit 1
fi

echo "Repository directory: $(pwd)"
echo "Available files:"
ls -la

if [ ! -d "$PROJECT" ]; then
    echo "ERROR: $PROJECT not found in $(pwd)" >&2
    find . -maxdepth 4 -name "*.xcodeproj" -print
    exit 1
fi

mkdir -p "$BUILD_DIR"
DERIVED_DATA="$BUILD_DIR/DerivedData"

xcodebuild \
    -list -project "$PROJECT"

xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -derivedDataPath "$DERIVED_DATA" \
    -destination 'generic/platform=iOS' \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    DEVELOPMENT_TEAM=""

APP_PATH="$DERIVED_DATA/Build/Products/$CONFIG-iphoneos/Jade.app"

if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: Jade.app not found at $APP_PATH" >&2
    find "$DERIVED_DATA/Build/Products" -name "Jade.app" -print
    exit 1
fi

WORK_DIR="$BUILD_DIR/Jade"
IPA_PATH="$BUILD_DIR/Jade.ipa"

rm -rf "$WORK_DIR" "$IPA_PATH"
mkdir -p "$WORK_DIR/Payload"
cp -R "$APP_PATH" "$WORK_DIR/Payload/Jade.app"

codesign -f -s - "$WORK_DIR/Payload/Jade.app"

(
    cd "$WORK_DIR"
    zip -r -q "../Jade.ipa" Payload
)

echo "Created $IPA_PATH"
ls -lh "$IPA_PATH"
