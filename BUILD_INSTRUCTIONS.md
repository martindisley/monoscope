# Building Monoscope

This guide explains how to build the Monoscope macOS app.

## Prerequisites

You need **Xcode 15 or later** installed on your Mac to build this application.

### Installing Xcode

1. Open the **Mac App Store**
2. Search for "Xcode"
3. Click **Get** or **Install**
4. Wait for the ~15GB download to complete
5. Open Xcode once to accept the license agreement

**Important**: Command Line Tools alone are NOT sufficient. You must install the full Xcode application from the App Store.

---

## Method 1: Build with Xcode GUI (Recommended)

This is the easiest method and allows you to run the app directly.

### Steps

1. **Install Xcode** (see above)

2. **Create the Xcode Project**
   
   Since the source files are already created, you need to create an Xcode project:
   
   ```bash
   cd ~/workspace/monoscope
   ```
   
   Then follow these steps in Xcode:
   
   - Open Xcode
   - File → New → Project
   - Choose **macOS → App**
   - Product Name: `Monoscope`
   - Organization Identifier: `com.yourname` (or your domain)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save location: `~/workspace/monoscope` (choose the existing directory)

3. **Add Source Files to Project**
   
   - In Xcode, right-click the `Monoscope` folder in the navigator
   - Select **Add Files to "Monoscope"...**
   - Navigate to `~/workspace/monoscope/Monoscope`
   - Select ALL folders: `App/`, `Core/`, `Settings/`, `UI/`, `Utilities/`
   - Make sure **"Copy items if needed"** is UNCHECKED
   - Click **Add**

4. **Configure Info.plist**
   
   - Replace the default `Info.plist` with the one in `Monoscope/App/Info.plist`
   - Or manually merge the URL scheme settings

5. **Configure Signing**
   
   - Select the project in the navigator
   - Select the `Monoscope` target
   - Go to **Signing & Capabilities** tab
   - Select your **Team** (your Apple ID)
   - Xcode will automatically manage signing

6. **Remove Default Files**
   
   Delete these auto-generated files (if they exist):
   - `ContentView.swift`
   - `MonoscopeApp.swift` (we use `main.swift` and `AppDelegate.swift` instead)

7. **Build and Run**
   
   - Press `Cmd+R` or click the **Run** button
   - The app should compile and launch
   - Test by clicking a link in Mail or Messages

---

## Method 2: Automated Xcode Project Creation

If you want to automate project creation, here's a script approach:

### Create Project Script

```bash
#!/bin/bash
# create_xcode_project.sh

cd ~/workspace/monoscope

# This requires having Xcode installed
# We'll use xcodegen (install via: brew install xcodegen)

cat > project.yml << 'EOF'
name: Monoscope
options:
  bundleIdPrefix: com.yourname
  deploymentTarget:
    macOS: "13.0"

targets:
  Monoscope:
    type: application
    platform: macOS
    sources:
      - Monoscope
    info:
      path: Monoscope/App/Info.plist
    entitlements:
      path: Monoscope/App/Monoscope.entitlements
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.yourname.Monoscope
      INFOPLIST_FILE: Monoscope/App/Info.plist
      CODE_SIGN_ENTITLEMENTS: Monoscope/App/Monoscope.entitlements
      MACOSX_DEPLOYMENT_TARGET: "13.0"
      SWIFT_VERSION: "5.0"
      PRODUCT_NAME: Monoscope
EOF

# Generate project
xcodegen generate
EOF

chmod +x create_xcode_project.sh
```

Then run:

```bash
brew install xcodegen
./create_xcode_project.sh
open Monoscope.xcodeproj
```

---

## Method 3: Command Line Build

Once you have an Xcode project file:

```bash
cd ~/workspace/monoscope

# Build for release
xcodebuild \
  -project Monoscope.xcodeproj \
  -scheme Monoscope \
  -configuration Release \
  -derivedDataPath ./build \
  clean build

# The app will be at:
# ./build/Build/Products/Release/Monoscope.app
```

---

## Manual Setup (Creating the Xcode Project File)

If you want to manually create the project structure:

### Step 1: File Structure

Your final structure should be:

```
monoscope/
├── Monoscope.xcodeproj/
│   └── project.pbxproj          # ← This is what you need to create
├── Monoscope/
│   ├── App/
│   ├── Core/
│   ├── Settings/
│   ├── UI/
│   └── Utilities/
├── README.md
└── TESTING.md
```

### Step 2: Create Minimal project.pbxproj

The easiest way is to use Xcode GUI (Method 1), but if you must create it manually, you'll need to write a complex XML-like file that defines:

- File references for all `.swift` files
- Build phases (compile sources, copy resources)
- Build settings (deployment target, signing, etc.)
- Target configuration

**This is extremely error-prone.** Use Method 1 or Method 2 instead.

---

## Post-Build Steps

### 1. Move to Applications

```bash
cp -R ./build/Build/Products/Release/Monoscope.app /Applications/
```

### 2. Set as Default Browser

1. Open **System Settings**
2. Go to **Desktop & Dock**
3. Scroll to **Default web browser**
4. Select **Monoscope**

### 3. Test

- Open Mail and click a link
- Should open in Monoscope!

---

## Troubleshooting

### "You need to install Xcode"

- Install Xcode from the Mac App Store
- Open it once to accept the license
- Run: `sudo xcode-select --switch /Applications/Xcode.app`

### "No such module 'SwiftUI'"

- Make sure deployment target is macOS 13.0+
- Check Build Settings → Base SDK is "macOS"

### "Code signing error"

- In Xcode: Signing & Capabilities → Select your Team
- Or for testing: Set "Signing Certificate" to "Sign to Run Locally"

### "Cannot find 'Constants' in scope" (LSP errors)

- These are just editor warnings from the language server
- They don't affect compilation
- They'll disappear once the Xcode project is properly configured

### Build Succeeds But App Doesn't Register as Browser

- Check `Info.plist` has `CFBundleURLTypes` correctly set
- Rebuild and reinstall the app
- Log out and log back in (LaunchServices cache)
- Run: `/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Monoscope.app`

---

## Development Workflow

### Quick Iterations

1. Make code changes
2. Press `Cmd+R` in Xcode
3. App rebuilds and launches automatically
4. Test the feature
5. Repeat

### Debugging

- Use `print()` statements (visible in Xcode console)
- Set breakpoints in Xcode
- Use Console.app to view system logs
- Check `~/Library/Logs/` for crash reports

---

## Distribution

### For Personal Use

The build instructions above are sufficient. Just move the `.app` to `/Applications`.

### For Others (Notarization Required)

To distribute to other users:

1. **Join Apple Developer Program** ($99/year)
2. **Code sign with Developer ID**
3. **Notarize the app** with Apple
4. **Staple the notarization ticket**
5. Create a DMG or ZIP for distribution

Details: https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution

---

## Next Steps

Once built, see:

- [README.md](README.md) for usage instructions
- [TESTING.md](TESTING.md) for comprehensive test checklist
- Source code comments for technical details

---

## Questions?

If you encounter issues not covered here:

1. Check Xcode build logs for specific errors
2. Verify all Swift files are included in the target
3. Ensure Info.plist and entitlements are correctly set
4. Check deployment target matches your macOS version

**Remember**: Xcode (the full app) is REQUIRED. Command Line Tools alone will not work for this project.
