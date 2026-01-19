#!/bin/bash

echo "🔨 Rebuilding Monoscope..."
cd ~/workspace/monoscope

# Clean build
xcodebuild -project Monoscope.xcodeproj -scheme Monoscope -configuration Debug clean

# Build
xcodebuild -project Monoscope.xcodeproj -scheme Monoscope -configuration Debug build

# Find and copy to Applications
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Monoscope-*/Build/Products/Debug -name "Monoscope.app" -type d 2>/dev/null | head -1)

if [ -n "$APP_PATH" ]; then
    echo "✅ Build successful!"
    
    # Ad-hoc code sign the app
    echo "🔏 Code signing..."
    codesign --force --deep --sign - "$APP_PATH"
    
    echo "📦 Copying to /Applications..."
    rm -rf /Applications/Monoscope.app
    cp -R "$APP_PATH" /Applications/
    echo "✅ Installed to /Applications/Monoscope.app"
    
    # Register with LaunchServices
    echo "🔄 Registering with LaunchServices..."
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Monoscope.app
    
    echo ""
    echo "✅ Done! Now:"
    echo "   1. Log out and log back in (or restart)"
    echo "   2. Go to System Settings → Desktop & Dock"
    echo "   3. Look for Monoscope in Default web browser"
else
    echo "❌ Build failed or app not found"
fi
