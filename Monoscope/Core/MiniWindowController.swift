//
//  MiniWindowController.swift
//  Monoscope
//
//  Manages the frameless floating window containing a WebView
//

import Cocoa

class MiniWindowController: NSWindowController, NSWindowDelegate {
    
    private var webViewController: WebViewController!
    var onClose: ((MiniWindowController) -> Void)?
    
    convenience init(url: URL) {
        // Create the frameless panel
        let panel = NSPanel(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: Constants.defaultWindowWidth,
                height: Constants.defaultWindowHeight
            ),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.init(window: panel)
        
        // Configure window appearance
        setupWindowAppearance(panel)
        
        // Create and set up web view controller
        webViewController = WebViewController(url: url)
        webViewController.onRequestClose = { [weak self] in
            self?.close()
        }
        
        panel.contentViewController = webViewController
        
        // Center on screen with mouse pointer
        centerWindowOnActiveScreen(panel)
        
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
        
        // Window level
        updateWindowLevel()
        
        // Make sure window accepts key events
        panel.isFloatingPanel = false
        panel.hidesOnDeactivate = false
        
        // Standard window behavior
        panel.collectionBehavior = [.managed, .participatesInCycle]
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
        
        if SettingsStore.shared.settings.alwaysOnTop {
            window.level = .floating
        } else {
            window.level = .normal
        }
    }
    
    func updateFloatingButtonVisibility() {
        webViewController.updateFloatingButtonVisibility()
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        onClose?(self)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        // Ensure web view is first responder for keyboard shortcuts
        webViewController.view.window?.makeFirstResponder(webViewController)
    }
}
