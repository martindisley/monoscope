//
//  MiniWindowController.swift
//  Monoscope
//
//  Manages the frameless floating window containing a WebView
//

import Cocoa

final class NonActivatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

class MiniWindowController: NSWindowController, NSWindowDelegate {
    
    private var webViewController: WebViewController!
    var onClose: ((MiniWindowController) -> Void)?
    
    convenience init(url: URL) {
        // Create the frameless panel with default size
        let usesNonActivatingWindows = SettingsStore.shared.settings.nonActivatingWindows
        var styleMask: NSWindow.StyleMask = [.titled, .closable, .resizable, .fullSizeContentView]
        if usesNonActivatingWindows {
            styleMask.insert(.nonactivatingPanel)
        }
        let panel = NonActivatingPanel(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: Constants.defaultWindowWidth,
                height: Constants.defaultWindowHeight
            ),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        
        print("🏗 Created panel with frame: \(panel.frame)")
        
        self.init(window: panel)
        
        print("🏗 After init, frame: \(panel.frame)")
        
        // Configure window appearance
        setupWindowAppearance(panel)
        
        print("🏗 After appearance setup, frame: \(panel.frame)")
        
        // Create and set up web view controller
        webViewController = WebViewController(url: url)
        webViewController.onRequestClose = { [weak self] in
            self?.close()
        }
        
        panel.contentViewController = webViewController
        
        print("🏗 After setting content view, frame: \(panel.frame)")
        
        // Restore saved window size if available
        restoreWindowFrame(panel)
        
        print("🏗 After restore, frame: \(panel.frame)")
        
        // Center on screen with mouse pointer
        centerWindowOnActiveScreen(panel)
        
        print("🏗 After centering, frame: \(panel.frame)")
        
        // Set delegate
        panel.delegate = self
    }
    
    private func setupWindowAppearance(_ panel: NSPanel) {
        // Frameless appearance
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovableByWindowBackground = true
        
        // Styling
        panel.backgroundColor = .black
        panel.hasShadow = true
        panel.isOpaque = false
        
        // Hide minimize and maximize buttons (keep only close button)
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        
        // Window level and space behavior
        updateWindowLevel()

        // Activation behavior
        updateActivationBehavior()
        
        // Make sure window accepts key events
        panel.isFloatingPanel = false
        panel.hidesOnDeactivate = false
        
        // Standard window behavior (specifics set in updateWindowLevel)
    }
    
    private func centerWindowOnActiveScreen(_ window: NSWindow) {
        // Get screen containing mouse pointer
        let mouseLocation = NSEvent.mouseLocation
        var targetScreen = NSScreen.main
        
        for screen in NSScreen.screens {
            if NSPointInRect(mouseLocation, screen.frame) {
                targetScreen = screen
                break
            }
        }
        
        // Center on that screen
        if let screen = targetScreen {
            let screenFrame = screen.visibleFrame
            let windowFrame = window.frame
            
            let x = screenFrame.midX - windowFrame.width / 2
            let y = screenFrame.midY - windowFrame.height / 2
            
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
    
    func updateWindowLevel() {
        guard let window = window else { return }
        let baseBehavior: NSWindow.CollectionBehavior = [.managed, .participatesInCycle, .moveToActiveSpace]
        
        if SettingsStore.shared.settings.alwaysOnTop {
            window.level = .floating
            window.collectionBehavior = baseBehavior.union([.canJoinAllSpaces, .fullScreenAuxiliary])
        } else {
            window.level = .normal
            window.collectionBehavior = baseBehavior
        }
    }

    func updateActivationBehavior() {
        guard let panel = window as? NSPanel else { return }

        if SettingsStore.shared.settings.nonActivatingWindows {
            panel.styleMask.insert(.nonactivatingPanel)
            panel.hidesOnDeactivate = false
        } else {
            panel.styleMask.remove(.nonactivatingPanel)
        }
    }
    
    func updateFloatingButtonVisibility() {
        webViewController.updateFloatingButtonVisibility()
    }
    
    // MARK: - Window Frame Persistence
    
    private func restoreWindowFrame(_ window: NSWindow) {
        let defaults = UserDefaults.standard
        if let widthValue = defaults.value(forKey: "MonoscopeWindowWidth") as? CGFloat,
           let heightValue = defaults.value(forKey: "MonoscopeWindowHeight") as? CGFloat,
           widthValue > 100 && heightValue > 100 { // Sanity check
            var frame = window.frame
            frame.size.width = widthValue
            frame.size.height = heightValue
            window.setFrame(frame, display: false)
            print("📐 Restored window size: \(widthValue)x\(heightValue)")
        } else {
            print("📐 Using default window size: \(Constants.defaultWindowWidth)x\(Constants.defaultWindowHeight)")
        }
    }
    
    private func saveWindowFrame() {
        guard let window = window else { return }
        let frame = window.frame
        if frame.size.width > 100 && frame.size.height > 100 { // Sanity check
            let defaults = UserDefaults.standard
            defaults.set(frame.size.width, forKey: "MonoscopeWindowWidth")
            defaults.set(frame.size.height, forKey: "MonoscopeWindowHeight")
            print("💾 Saved window size: \(frame.size.width)x\(frame.size.height)")
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        saveWindowFrame()
        onClose?(self)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        // Ensure web view is first responder for keyboard shortcuts
        webViewController.view.window?.makeFirstResponder(webViewController)
    }
    
    func windowDidResize(_ notification: Notification) {
        // Save size when user manually resizes
        saveWindowFrame()
    }
}
