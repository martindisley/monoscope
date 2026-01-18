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
        
        // Validate URL
        guard url.scheme == "http" || url.scheme == "https" else {
            print("⚠️ Invalid URL scheme for Monoscope: \(url.scheme ?? "nil")")
            // Forward non-http(s) URLs to system
            NSWorkspace.shared.open(url)
            return
        }
        
        // Create new window
        let windowController = MiniWindowController(url: url)
        
        // Register with app delegate for tracking
        appDelegate?.registerWindow(windowController)
        
        // Show window
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
    }
    
    /// Opens multiple URLs (each in its own window)
    func openURLs(_ urls: [URL]) {
        for url in urls {
            openInNewWindow(url)
        }
    }
}
