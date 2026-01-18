#!/bin/bash

# Monoscope - Xcode Project Setup Script
# This script creates an Xcode project using xcodegen

set -e  # Exit on error

echo "🚀 Monoscope - Xcode Project Setup"
echo "===================================="
echo ""

# Check if we're in the right directory
if [ ! -f "project.yml" ]; then
    echo "❌ Error: project.yml not found"
    echo "   Please run this script from the monoscope directory"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed"
    echo ""
    echo "Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✅ Homebrew found"

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "📦 Installing xcodegen..."
    brew install xcodegen
fi

echo "✅ xcodegen found"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed"
    echo ""
    echo "Please install Xcode from the Mac App Store:"
    echo "  https://apps.apple.com/us/app/xcode/id497799835"
    echo ""
    echo "After installing, run this script again."
    exit 1
fi

echo "✅ Xcode found"

# Generate the Xcode project
echo ""
echo "🔨 Generating Xcode project..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Xcode project created successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Open the project: open Monoscope.xcodeproj"
    echo "   2. Select your development team in Signing & Capabilities"
    echo "   3. Press Cmd+R to build and run"
    echo ""
    echo "📖 For detailed build instructions, see: BUILD_INSTRUCTIONS.md"
    echo "📋 For testing, see: TESTING.md"
    echo ""
    
    # Offer to open the project
    read -p "Would you like to open the project in Xcode now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open Monoscope.xcodeproj
    fi
else
    echo ""
    echo "❌ Failed to generate Xcode project"
    echo "   Check the error messages above"
    exit 1
fi
