//
//  AppDelegate.swift
//  Monoscope
//
//  Main application delegate
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var openWindows: [MiniWindowController] = []
    private var urlRouter: URLRouter!
    private var menuBarManager: MenuBarManager!
    private var pendingURLs: [URL] = []
    private var isReady = false
    private var welcomeWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("🚀 Monoscope launching...")

        // Keep Monoscope out of the Dock and avoid app activation
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize URL router
        urlRouter = URLRouter()
        urlRouter.appDelegate = self
        
        // Setup menu bar
        menuBarManager = MenuBarManager()
        menuBarManager.appDelegate = self
        menuBarManager.setupMenuBar()
        
        // Setup notification observers
        setupNotificationObservers()
        
        // Check if first launch
        if !SettingsStore.shared.hasSeenWelcome() {
            showWelcomeScreen()
        }
        
        // Mark as ready
        isReady = true
        
        // Process any pending URLs that arrived during launch
        if !pendingURLs.isEmpty {
            print("📦 Processing \(pendingURLs.count) pending URLs")
            urlRouter.openURLs(pendingURLs)
            pendingURLs.removeAll()
        }
        
        print("✅ Monoscope ready")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        print("👋 Monoscope terminating")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when all windows are closed - stay running in menu bar
        return false
    }
    
    // MARK: - URL Handling
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print("📬 Received \(urls.count) URL(s) to open")
        
        if isReady {
            urlRouter.openURLs(urls)
        } else {
            // Queue URLs if app not yet ready
            print("⏳ App not ready, queuing URLs")
            pendingURLs.append(contentsOf: urls)
        }
    }

    func openURLInMonoscope(_ url: URL) {
        urlRouter.openInNewWindow(url)
    }
    
    // MARK: - Window Management
    
    func registerWindow(_ windowController: MiniWindowController) {
        windowController.onClose = { [weak self] closedController in
            self?.unregisterWindow(closedController)
        }
        openWindows.append(windowController)
        print("📝 Registered window (total: \(openWindows.count))")
    }
    
    private func unregisterWindow(_ windowController: MiniWindowController) {
        openWindows.removeAll { $0 === windowController }
        print("🗑 Unregistered window (remaining: \(openWindows.count))")
    }
    
    // MARK: - Welcome Screen
    
    private func showWelcomeScreen() {
        let welcomeView = WelcomeView()
        let hostingController = NSHostingController(rootView: welcomeView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Welcome to Monoscope"
        window.styleMask = [.titled, .closable]
        window.center()
        window.isReleasedWhenClosed = true
        window.makeKeyAndOrderFront(nil)
        
        welcomeWindow = window
    }
    
    // MARK: - Notification Observers
    
    private func setupNotificationObservers() {
        // Listen for settings changes to update open windows
        NotificationCenter.default.addObserver(
            forName: .settingsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAllWindowsUI()
        }
        
        NotificationCenter.default.addObserver(
            forName: .windowLevelDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAllWindowLevels()
        }

        NotificationCenter.default.addObserver(
            forName: .windowActivationDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAllWindowActivationBehavior()
        }
    }
    
    private func updateAllWindowsUI() {
        for windowController in openWindows {
            windowController.updateFloatingButtonVisibility()
        }
    }
    
    private func updateAllWindowLevels() {
        for windowController in openWindows {
            windowController.updateWindowLevel()
        }
    }

    private func updateAllWindowActivationBehavior() {
        for windowController in openWindows {
            windowController.updateActivationBehavior()
        }
    }
}
