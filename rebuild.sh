#!/bin/bash
set -euo pipefail

echo "🔨 Rebuilding Monoscope..."

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DERIVED_DATA_PATH="$REPO_DIR/.derivedData"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug/Monoscope.app"

cd "$REPO_DIR"

xcodebuild -project Monoscope.xcodeproj -scheme Monoscope -configuration Debug -derivedDataPath "$DERIVED_DATA_PATH" build

if [ -d "$APP_PATH" ]; then
    echo "✅ Build successful!"
    echo "📦 Installing to /Applications..."
    /usr/bin/ditto "$APP_PATH" "/Applications/Monoscope.app"
    echo "✅ Installed /Applications/Monoscope.app"

    echo "🔄 Registering with LaunchServices..."
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Monoscope.app
else
    echo "❌ Build failed: app not found at $APP_PATH"
    exit 1
fi
