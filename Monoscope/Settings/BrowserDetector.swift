//
//  BrowserDetector.swift
//  Monoscope
//
//  Detects installed browsers on the system
//

import Foundation
import AppKit

struct BrowserInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let appURL: URL
    let bundleIdentifier: String
    let icon: NSImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }
    
    static func == (lhs: BrowserInfo, rhs: BrowserInfo) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}

class BrowserDetector {
    
    /// Scans common application paths for installed browsers
    static func findInstalledBrowsers() -> [BrowserInfo] {
        var browsers: [BrowserInfo] = []
        
        for (name, path) in Constants.commonBrowsers {
            let url = URL(fileURLWithPath: path)
            
            // Check if the app exists
            guard FileManager.default.fileExists(atPath: path) else {
                continue
            }
            
            // Try to get bundle info
            guard let bundle = Bundle(url: url),
                  let bundleId = bundle.bundleIdentifier else {
                continue
            }
            
            // Get app icon
            let icon = NSWorkspace.shared.icon(forFile: path)
            
            let browser = BrowserInfo(
                name: name,
                appURL: url,
                bundleIdentifier: bundleId,
                icon: icon
            )
            
            browsers.append(browser)
        }
        
        return browsers
    }
    
    /// Returns the default Safari browser info
    static func getSafariBrowser() -> BrowserInfo? {
        let safariPath = "/Applications/Safari.app"
        let url = URL(fileURLWithPath: safariPath)
        
        guard FileManager.default.fileExists(atPath: safariPath),
              let bundle = Bundle(url: url),
              let bundleId = bundle.bundleIdentifier else {
            return nil
        }
        
        let icon = NSWorkspace.shared.icon(forFile: safariPath)
        
        return BrowserInfo(
            name: "Safari",
            appURL: url,
            bundleIdentifier: bundleId,
            icon: icon
        )
    }
}
