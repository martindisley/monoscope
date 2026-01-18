# Monoscope - Manual Testing Checklist

This document contains a comprehensive test suite for validating all Monoscope features.

## Prerequisites

- [ ] Monoscope built successfully
- [ ] App moved to `/Applications`
- [ ] macOS 13.0+ (Ventura or later)

---

## 🚀 Setup Tests

### Initial Launch
- [ ] App launches without crashes
- [ ] Welcome screen appears on first launch
- [ ] Welcome screen explains how to set as default browser
- [ ] "Get Started" button closes welcome screen
- [ ] Welcome screen does not appear on second launch

### Menu Bar
- [ ] Menu bar icon appears (network symbol)
- [ ] Menu bar icon adapts to light mode
- [ ] Menu bar icon adapts to dark mode
- [ ] Clicking icon shows menu with: Settings, About, Quit
- [ ] Menu items have correct keyboard shortcuts displayed

---

## 🌐 Default Browser Registration (FR-1)

### System Integration
- [ ] Open System Settings → Desktop & Dock
- [ ] "Monoscope" appears in "Default web browser" dropdown
- [ ] Successfully set Monoscope as default browser
- [ ] System remembers selection after reboot

---

## 🔗 External Link Opens (FR-2)

### Creating New Windows
- [ ] Click http link in **Mail** → opens in NEW Monoscope window
- [ ] Click https link in **Messages** → opens in NEW window
- [ ] Click link in **Notes** → opens in NEW window
- [ ] Click link in **Slack** (if installed) → opens in NEW window
- [ ] Click link in **Discord** (if installed) → opens in NEW window
- [ ] Click two links quickly in Mail → creates TWO separate windows
- [ ] Each window is independent (separate navigation history)

### URL Validation
- [ ] Test regular URL: `https://example.com` → loads correctly
- [ ] Test URL with path: `https://example.com/path/to/page` → loads correctly
- [ ] Test URL with query: `https://example.com?foo=bar&baz=qux` → loads correctly
- [ ] Test URL with fragment: `https://example.com#section` → loads and scrolls to section
- [ ] Test localhost: `http://localhost:3000` → loads correctly
- [ ] Test IP address: `http://192.168.1.1` → loads correctly
- [ ] Test URL with port: `https://example.com:8080` → loads correctly
- [ ] Test very long URL (1000+ chars) → no truncation, loads correctly
- [ ] Test malformed URL → app doesn't crash (may show error page)
- [ ] Test non-existent domain → shows browser error page (not crash)

---

## 🔄 Internal Navigation (FR-3)

### Same-Window Navigation
- [ ] Click regular `<a href>` link in page → navigates in SAME window
- [ ] Click link with `target="_blank"` → stays in SAME window (doesn't create new)
- [ ] Page with `window.open()` call → opens in SAME window
- [ ] JavaScript redirect → navigates in SAME window
- [ ] Form submission → stays in SAME window
- [ ] Meta refresh redirect → stays in SAME window

### Navigation History
- [ ] Press `Cmd+[` (back) → goes to previous page
- [ ] Press `Cmd+]` (forward) → goes to next page
- [ ] Back button works correctly with multiple pages
- [ ] Forward button works after going back
- [ ] Cannot go back on first page (Cmd+[ does nothing)
- [ ] Cannot go forward on latest page (Cmd+] does nothing)

### Page Reload
- [ ] Press `Cmd+R` → page reloads
- [ ] Reload preserves scroll position (if possible)
- [ ] Reload works on error pages

---

## 🎨 Window UI (FR-4, W-1 to W-5)

### Frameless Appearance
- [ ] Window has NO visible title bar
- [ ] Window has NO address bar
- [ ] Window has rounded corners
- [ ] Window has shadow (visual depth)
- [ ] Window background is black (no white flash on load)
- [ ] Web content fills entire window

### Window Controls
- [ ] Red close button (●) is visible and works
- [ ] Yellow minimize button (●) is visible and works
- [ ] Green zoom button (●) is visible and works

### Dragging
- [ ] Can drag window by clicking empty area near top
- [ ] Can drag window while web page is loading
- [ ] Cannot accidentally drag when interacting with web content

### Resizing
- [ ] Can resize from left edge
- [ ] Can resize from right edge
- [ ] Can resize from top edge
- [ ] Can resize from bottom edge
- [ ] Can resize from corners (diagonal)
- [ ] WebView content scales correctly when resizing
- [ ] Minimum window size is reasonable (~400×300)

### Window Placement
- [ ] First window opens centered on screen with mouse cursor
- [ ] Second window opens centered (may overlap first)
- [ ] Windows on multi-monitor setup open on correct screen

### Closing
- [ ] Click red close button → window closes
- [ ] Press `Cmd+W` → window closes
- [ ] Press `Esc` (with setting enabled) → window closes
- [ ] Closing window releases resources (no memory leak)
- [ ] Closing one window doesn't affect others

---

## 🎛️ Floating Open Button (FR-5)

### Button Appearance
- [ ] Button appears in top-right corner
- [ ] Button shows "Open" text + arrow icon
- [ ] Button has backdrop blur effect (ultraThinMaterial)
- [ ] Button is semi-transparent
- [ ] Button margin is 16px from edges
- [ ] Button stays visible when scrolling page

### Button Functionality
- [ ] Clicking button opens current URL in main browser
- [ ] Button works even when no main browser is selected (falls back to Safari)
- [ ] Button respects "close after open" setting

### Settings Toggle
- [ ] Open Settings → toggle "Show floating button" OFF → button disappears
- [ ] Toggle back ON → button reappears
- [ ] Setting change affects ALL open windows immediately
- [ ] Cmd+O still works when button is hidden

---

## ⌨️ Keyboard Shortcuts (FR-6)

### Primary Shortcuts
- [ ] `Cmd+O` → Opens current page in main browser
- [ ] `Cmd+W` → Closes window
- [ ] `Cmd+R` → Reloads page
- [ ] `Cmd+[` → Goes back (if history available)
- [ ] `Cmd+]` → Goes forward (if history available)

### Esc Key
- [ ] With setting ENABLED: `Esc` → closes window
- [ ] With setting DISABLED: `Esc` → does nothing (page may handle it)
- [ ] Toggle setting in Settings and verify behavior changes

### Focus Handling
- [ ] Shortcuts work when web page has focus
- [ ] Shortcuts work when address bar would have focus (N/A - no address bar)
- [ ] Shortcuts work immediately after window opens
- [ ] Shortcuts work on pages with heavy JavaScript

---

## 🚀 Open in Main Browser (FR-7)

### Browser Selection
- [ ] Open Settings → Main Browser section shows installed browsers
- [ ] Safari appears as default option
- [ ] Other installed browsers appear with icons
- [ ] Can select Chrome (if installed)
- [ ] Can select Firefox (if installed)
- [ ] Can select Arc (if installed)
- [ ] Can select Zen (if installed)
- [ ] Selection persists after app restart

### Opening Mechanism
- [ ] Press `Cmd+O` → page opens in selected browser
- [ ] Click floating "Open" button → page opens in selected browser
- [ ] Selected browser comes to front
- [ ] URL opens in NEW tab in the browser (not replacing existing tab)
- [ ] Opening does NOT loop back to Monoscope (critical!)
- [ ] With no browser selected → falls back to Safari
- [ ] If Safari not found → shows error or does nothing gracefully

### Close After Open
- [ ] With setting OFF: Window stays open after Cmd+O
- [ ] With setting ON: Window closes after Cmd+O
- [ ] With setting ON: Window closes after clicking Open button
- [ ] Setting change takes effect immediately

---

## ⚙️ Settings (SR-1 to SR-5)

### Settings Window
- [ ] Click menu bar → Settings → Settings window opens
- [ ] Settings window has title "Settings"
- [ ] Settings window is NOT frameless (has standard title bar)
- [ ] Settings window shows all sections: Main Browser, Appearance, Behavior
- [ ] Clicking Settings again brings existing window to front (doesn't create new)

### Main Browser Section
- [ ] Picker shows "Safari (default)"
- [ ] Picker shows all detected browsers with icons
- [ ] Selecting browser updates immediately
- [ ] Selection persists after closing settings
- [ ] Selection persists after app restart

### Appearance Section
- [ ] "Show floating Open button" toggle → updates all windows immediately
- [ ] "Always on top" toggle → windows float above other apps
- [ ] Disabling "always on top" → windows behave normally

### Behavior Section
- [ ] "Close after open" toggle → affects Cmd+O behavior
- [ ] "Esc closes window" toggle → enables/disables Esc shortcut

### Version Info
- [ ] Settings shows app version number at bottom
- [ ] Version number is correct

---

## 📧 Non-HTTP Schemes (FR-8)

### Email Links
- [ ] Click `mailto:test@example.com` → opens Mail app (or default email client)
- [ ] Email address is pre-filled correctly
- [ ] Monoscope window does NOT navigate to mailto URL

### Phone Links
- [ ] Click `tel:+15551234567` → opens FaceTime or phone handler
- [ ] Phone number is passed correctly

### Custom App Schemes
- [ ] Click `slack://open` (if Slack installed) → opens Slack
- [ ] Click `zoom://join?confid=123` (if Zoom installed) → opens Zoom
- [ ] Click `spotify:track:xxx` (if Spotify installed) → opens Spotify
- [ ] Unknown scheme → either opens appropriate app or shows system error

### FTP Links
- [ ] Click `ftp://example.com` → forwards to Finder or FTP client

---

## 🪟 Multi-Window Tests

### Independence
- [ ] Open 5 different links → 5 separate windows
- [ ] Each window has its own navigation history
- [ ] Closing one window doesn't affect others
- [ ] Each window can have different zoom levels
- [ ] Each window can be on different virtual desktops

### Settings Propagation
- [ ] Change "Show button" setting → all windows update
- [ ] Change "Always on top" → all windows update
- [ ] Change "Main browser" → Cmd+O works correctly in all windows

---

## 📊 App Lifecycle

### Startup
- [ ] Cold start (app not running) → opens queued URL correctly
- [ ] App already running → new URL creates new window
- [ ] Click multiple links during startup → all open correctly
- [ ] Welcome screen on first launch doesn't block URL opens

### Background Behavior
- [ ] Close all windows → app stays running (menu bar icon visible)
- [ ] App in background → still receives URL opens
- [ ] Cmd+Tab shows Monoscope even with no windows

### Quit
- [ ] Menu bar → Quit → app terminates completely
- [ ] All windows close when quitting
- [ ] No zombie processes remain after quit

---

## 🎭 About Window

### About Dialog
- [ ] Menu bar → About → About window opens
- [ ] Shows app name "Monoscope"
- [ ] Shows version number
- [ ] Shows app icon or symbol
- [ ] Shows brief description
- [ ] Window is NOT frameless (standard title bar)
- [ ] Clicking About again brings window to front

---

## 🔍 Edge Cases

### Loading States
- [ ] Very slow page → doesn't hang UI
- [ ] Page that never loads → can still close window
- [ ] Page with tons of JavaScript → app remains responsive
- [ ] Page with auto-refresh → window stays open

### Web Content
- [ ] Page with embedded video → plays correctly
- [ ] Page with iframes → renders correctly
- [ ] Page with popups → opens in same window (not new window)
- [ ] Page with file download → shows download dialog
- [ ] Page requiring authentication → login works
- [ ] Page with geolocation request → shows permission dialog
- [ ] Page with notification request → shows permission dialog

### Network Conditions
- [ ] No internet connection → shows error page, doesn't crash
- [ ] Wi-Fi disconnects mid-load → shows error page
- [ ] Slow network → loading indicator (if visible) works

### Cookies & Storage
- [ ] Login to site → cookies persist between windows
- [ ] Login to site → cookies persist after app restart
- [ ] localStorage works correctly
- [ ] sessionStorage is per-window

---

## ⚡ Performance (NFR-1)

### Window Creation Speed
- [ ] Window appears within ~300ms of clicking external link
- [ ] No noticeable delay on cold start
- [ ] Opening 10 windows rapidly doesn't cause slowdown

### Rendering Performance
- [ ] Smooth scrolling on long pages
- [ ] Animations on web pages run smoothly (60 FPS)
- [ ] No jank when resizing window

### Memory
- [ ] Open 10 windows → memory usage reasonable (<500 MB)
- [ ] Close 10 windows → memory released
- [ ] Use app for 1 hour → no memory leak

---

## 🔒 Privacy (NFR-3)

### No Logging
- [ ] Check Console.app → no URLs logged in system logs
- [ ] Check app sandbox → no URL history files created
- [ ] No telemetry pings (use Charles Proxy or similar to verify)

---

## 🐛 Known Issues / Won't Fix

- [ ] None currently!

---

## ✅ Test Summary

**Date Tested**: _______________  
**Tester**: _______________  
**Version**: _______________  
**macOS Version**: _______________

**Pass Rate**: _____ / _____

**Critical Failures** (blocking release):
- 

**Minor Issues** (can ship):
-

**Notes**:
