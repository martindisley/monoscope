//
//  URLRouter.swift
//  Monoscope
//
//  Routes external URL opens to new windows
//

import Foundation
import AppKit

class URLRouter {
    
    weak var appDelegate: AppDelegate?
    
    /// Opens a URL in a new mini window
    func openInNewWindow(_ url: URL) {
        print("🌐 Opening URL in new window: \(url)")
        
        let scheme = url.scheme?.lowercased() ?? ""
        
        // Only open http(s) URLs in Monoscope windows
        guard scheme == "http" || scheme == "https" else {
            print("⚠️ Invalid URL scheme for Monoscope: \(scheme)")
            
            // Forward external schemes (mailto:, tel:, etc.) to system
            let externalSchemes = ["mailto", "tel", "sms", "facetime", "maps"]
            if externalSchemes.contains(scheme) {
                print("📤 Forwarding external URL to system: \(url)")
                NSWorkspace.shared.open(url)
            }
            // Ignore internal schemes like about:, data:, javascript:
            return
        }
        
        // Create new window
        let windowController = MiniWindowController(url: url)
        
        // Register with app delegate for tracking
        appDelegate?.registerWindow(windowController)
        
        // Show window with optional activation behavior
        windowController.showWindow(nil)
        if SettingsStore.shared.settings.nonActivatingWindows {
            windowController.window?.orderFrontRegardless()
        } else {
            windowController.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // Debug: Print window frame
        if let window = windowController.window {
            print("🪟 Window frame: \(window.frame)")
            print("🪟 Window visible: \(window.isVisible)")
            print("🪟 Window on screen: \(window.isOnActiveSpace)")
        }
    }
    
    /// Opens multiple URLs (each in its own window)
    func openURLs(_ urls: [URL]) {
        for url in urls {
            openInNewWindow(url)
        }
    }
}
