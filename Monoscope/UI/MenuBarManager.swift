//
//  MenuBarManager.swift
//  Monoscope
//
//  Manages the menu bar status item
//

import Cocoa
import SwiftUI
import WebKit

class MenuBarManager: NSObject {
    
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?
    private var clearSiteMenuItem: NSMenuItem?
    private var historyMenuItem: NSMenuItem?
    private let historyMenu = NSMenu()
    private var lastVisitedHost: String?
    
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
        menu.delegate = self
        
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

        let historyItem = NSMenuItem(title: "History", action: nil, keyEquivalent: "")
        historyItem.submenu = historyMenu
        menu.addItem(historyItem)
        historyMenuItem = historyItem

        let clearSiteItem = NSMenuItem(
            title: "Clear Data for This Site",
            action: #selector(clearWebsiteDataForCurrentSite),
            keyEquivalent: ""
        )
        menu.addItem(clearSiteItem)
        clearSiteMenuItem = clearSiteItem

        menu.addItem(
            NSMenuItem(
                title: "Clear All Browser Data",
                action: #selector(clearWebsiteData),
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentURLDidChange(_:)),
            name: .currentURLDidChange,
            object: nil
        )
        
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

    @objc func currentURLDidChange(_ notification: Notification) {
        guard let url = notification.object as? URL else {
            lastVisitedHost = nil
            return
        }
        lastVisitedHost = url.host
    }

    @objc func clearWebsiteData() {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()

        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: .distantPast) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .websiteDataDidClear, object: nil)
                print("🗑️ Cleared website data")
            }
        }
    }

    @objc func clearWebsiteDataForCurrentSite() {
        guard let host = lastVisitedHost, !host.isEmpty else {
            NSSound.beep()
            return
        }

        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: dataTypes) { records in
            let matchingRecords = records.filter { record in
                record.displayName == host || record.displayName.hasSuffix(".\(host)")
            }

            WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, for: matchingRecords) {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .websiteDataDidClear, object: nil)
                    print("🗑️ Cleared website data for \(host)")
                }
            }
        }
    }

    @objc func openHistoryEntry(_ sender: NSMenuItem) {
        guard let urlString = sender.representedObject as? String,
              let url = URL(string: urlString) else {
            return
        }
        appDelegate?.openURLInMonoscope(url)
    }

    @objc func clearHistory() {
        HistoryStore.shared.clear()
        rebuildHistoryMenu()
    }

    private func rebuildHistoryMenu() {
        historyMenu.removeAllItems()

        let entries = HistoryStore.shared.entries(limitToMenu: true)
        if entries.isEmpty {
            let item = NSMenuItem(title: "No history yet", action: nil, keyEquivalent: "")
            item.isEnabled = false
            historyMenu.addItem(item)
            return
        }

        for entry in entries {
            let item = NSMenuItem(title: entry.displayTitle, action: #selector(openHistoryEntry(_:)), keyEquivalent: "")
            item.representedObject = entry.urlString
            item.target = self
            historyMenu.addItem(item)
        }

        historyMenu.addItem(NSMenuItem.separator())
        let clearItem = NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: "")
        clearItem.target = self
        historyMenu.addItem(clearItem)
    }
}

extension MenuBarManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        rebuildHistoryMenu()
        clearSiteMenuItem?.isEnabled = (lastVisitedHost != nil)
    }
}
