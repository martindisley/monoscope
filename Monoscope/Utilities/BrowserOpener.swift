//
//  BrowserOpener.swift
//  Monoscope
//
//  Opens URLs in the user's selected main browser
//

import Foundation
import AppKit

class BrowserOpener {
    
    /// Opens the given URL in the specified browser app, or falls back to Safari
    static func openURL(_ url: URL, inBrowser browserAppURL: URL?, completion: ((Bool) -> Void)? = nil) {
        // Determine which browser to use
        let targetBrowser: URL
        
        if let browserAppURL = browserAppURL {
            targetBrowser = browserAppURL
        } else {
            // Fallback to Safari
            let safariPath = "/Applications/Safari.app"
            if FileManager.default.fileExists(atPath: safariPath) {
                targetBrowser = URL(fileURLWithPath: safariPath)
            } else {
                print("⚠️ No browser specified and Safari not found")
                completion?(false)
                return
            }
        }
        
        // Open URL in the specific browser app
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true // Bring browser to front
        
        NSWorkspace.shared.open(
            [url],
            withApplicationAt: targetBrowser,
            configuration: config
        ) { _, error in
            if let error = error {
                print("❌ Error opening URL in browser: \(error.localizedDescription)")
                // Try Safari as last resort if opening failed
                if targetBrowser.path != "/Applications/Safari.app" {
                    fallbackToSafari(url, completion: completion)
                } else {
                    completion?(false)
                }
            } else {
                print("✅ Successfully opened URL in browser: \(url)")
                completion?(true)
            }
        }
    }
    
    private static func fallbackToSafari(_ url: URL, completion: ((Bool) -> Void)?) {
        let safariURL = URL(fileURLWithPath: "/Applications/Safari.app")
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        
        NSWorkspace.shared.open(
            [url],
            withApplicationAt: safariURL,
            configuration: config
        ) { _, error in
            completion?(error == nil)
        }
    }
}
