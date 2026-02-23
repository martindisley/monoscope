# Monoscope

A minimal macOS browser designed as a quick preview layer before opening links in your main browser.

## Features

- **Frameless floating windows** – Distraction-free web content viewing
- **Keyboard-first workflow** – Press `Cmd+O` to open the current page in your main browser
- **Zero clutter** – No address bar, no toolbars, just content
- **Always available** – Stays running in menu bar for instant link opens
- **Privacy-focused** – No telemetry, no URL logging
- **Smart navigation** – Links open in the same window, external clicks create new windows

## Quick Start

### Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (for building from source)

### Building

**Option 1: Open in Xcode**

1. Install Xcode from the Mac App Store
2. Open `Monoscope.xcodeproj`
3. Select your development team in Signing & Capabilities
4. Click Product → Run (or press `Cmd+R`)

**Option 2: Build via Terminal** (requires Xcode to be installed)

```bash
cd ~/workspace/monoscope
xcodebuild -project Monoscope.xcodeproj -scheme Monoscope -configuration Release build
```

### Installation

1. Build the app using one of the methods above
2. Find `Monoscope.app` in the build products
3. Drag it to `/Applications`
4. Launch Monoscope
5. Follow the welcome screen instructions

## Setting as Default Browser

1. Open **System Settings**
2. Navigate to **Desktop & Dock**
3. Scroll down to **Default web browser**
4. Select **Monoscope**

Now when you click links in Mail, Messages, Slack, or any other app, they'll open in Monoscope!

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+O` | Open current page in main browser |
| `Shift+Cmd+C` | Copy current URL to clipboard |
| `Cmd+W` | Close window |
| `Cmd+R` | Reload page |
| `Cmd+[` | Go back |
| `Cmd+]` | Go forward |
| `Esc` | Close window (configurable) |

## Settings

Access settings via the menu bar icon (network symbol).

### Main Browser
Choose which browser to use when you press `Cmd+O`:
- Safari (default fallback)
- Chrome, Firefox, Arc, Zen, Brave, Edge, etc.

### Appearance
- **Show floating Open button** – Toggle the overlay button in the top-right
- **Always on top** – Keep windows above other apps

### Behavior
- **Close after open** – Auto-close window after sending to main browser
- **Esc closes window** – Enable/disable Escape key shortcut

## Architecture

```
Monoscope/
├── App/
│   ├── main.swift                 # Entry point
│   ├── AppDelegate.swift          # URL handling, window tracking
│   ├── Info.plist                 # URL scheme registration
│   └── Monoscope.entitlements # Sandbox permissions
├── Core/
│   ├── URLRouter.swift            # Routes URLs to windows
│   ├── MiniWindowController.swift # Frameless window management
│   └── WebViewController.swift    # WebKit integration
├── Settings/
│   ├── SettingsStore.swift        # UserDefaults persistence
│   ├── SettingsView.swift         # Settings UI
│   ├── BrowserDetector.swift      # Find installed browsers
│   └── WelcomeView.swift          # First-launch welcome
├── UI/
│   ├── FloatingButton.swift       # Overlay open button
│   ├── AboutView.swift            # About dialog
│   └── MenuBarManager.swift       # Menu bar icon
└── Utilities/
    ├── BrowserOpener.swift        # Open URLs in specific browsers
    └── Constants.swift            # App constants
```

## Testing

See [TESTING.md](TESTING.md) for the manual test checklist.

### Quick Smoke Test

1. Set Monoscope as default browser
2. Click a link in Mail → should open in Monoscope
3. Click link within page → should navigate in same window
4. Press `Cmd+O` → should open in your main browser (not loop back)
5. Test `mailto:` link → should open Mail app
6. Open Settings → change preferences

## Development

### Code Structure

- **AppDelegate** – Main coordinator, owns window array and URL router
- **URLRouter** – Creates new windows for external URL opens
- **MiniWindowController** – Manages frameless NSPanel
- **WebViewController** – WKWebView with navigation/UI delegates
- **SettingsStore** – Observable singleton for app settings

### Key Implementation Details

#### Preventing New Windows
```swift
// WKUIDelegate
func webView(_ webView: WKWebView, createWebViewWith...) -> WKWebView? {
    // Load in existing window instead of creating new
    webView.load(URLRequest(url: url))
    return nil
}
```

#### Opening in Main Browser (No Loop)
```swift
// Open in specific app, bypassing default browser
NSWorkspace.shared.open([url], 
                        withApplicationAt: browserAppURL,
                        configuration: config)
```

#### External vs Internal Navigation
- External: URLs from `application(_:open:)` → new window
- Internal: WKNavigationDelegate → same window
