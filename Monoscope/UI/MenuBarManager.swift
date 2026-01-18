//
//  MenuBarManager.swift
//  Monoscope
//
//  Manages the menu bar status item
//

import Cocoa
import SwiftUI

class MenuBarManager: NSObject {
    
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?
    
    weak var appDelegate: AppDelegate?
    
    func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let button = statusItem?.button else {
            print("❌ Failed to create status bar button")
            return
        }
        
        // Set icon - use SF Symbol
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let image = NSImage(systemSymbolName: "scope", accessibilityDescription: "Monoscope")
        button.image = image?.withSymbolConfiguration(config)
        button.image?.isTemplate = true // Adapts to light/dark mode
        
        // Create menu
        let menu = NSMenu()
        
        menu.addItem(
            NSMenuItem(
                title: "Settings...",
                action: #selector(openSettings),
                keyEquivalent: ","
            )
        )
        
        menu.addItem(
            NSMenuItem(
                title: "About Monoscope",
                action: #selector(openAbout),
                keyEquivalent: ""
            )
        )
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(
            NSMenuItem(
                title: "Quit Monoscope",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            )
        )
        
        // Set menu targets
        for item in menu.items where item.action != #selector(NSApplication.terminate(_:)) {
            item.target = self
        }
        
        statusItem?.menu = menu
        
        print("✅ Menu bar setup complete")
    }
    
    @objc func openSettings() {
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.center()
        window.setFrameAutosaveName("SettingsWindow")
        window.isReleasedWhenClosed = false
        
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
    }
    
    @objc func openAbout() {
        if let window = aboutWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let aboutView = AboutView()
        let hostingController = NSHostingController(rootView: aboutView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "About Monoscope"
        window.styleMask = [.titled, .closable]
        window.center()
        window.isReleasedWhenClosed = false
        
        aboutWindow = window
        window.makeKeyAndOrderFront(nil)
    }
}
