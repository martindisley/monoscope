//
//  WebViewController.swift
//  Monoscope
//
//  Manages WKWebView and implements navigation/UI delegates
//

import Cocoa
import WebKit
import SwiftUI

class WebViewController: NSViewController {
    
    private var webView: WKWebView!
    private var floatingButtonHost: NSHostingView<FloatingButton>?
    private var titleBarView: TitleBarView?
    private var initialURL: URL?
    
    var onRequestClose: (() -> Void)?
    
    init(url: URL) {
        self.initialURL = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        // Create the main container view with an initial size
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.black.cgColor
        view = containerView
    }
    
    private func addTitleBar() {
        // Create a title bar at the top
        let titleBar = TitleBarView(frame: NSRect(
            x: 0,
            y: view.bounds.height - Constants.titleBarHeight,
            width: view.bounds.width,
            height: Constants.titleBarHeight
        ))
        titleBar.autoresizingMask = [.width, .minYMargin]
        
        view.addSubview(titleBar)
        self.titleBarView = titleBar
        
        print("📐 Title bar frame: \(titleBar.frame)")
        print("📐 View bounds: \(view.bounds)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleBar()
        setupWebView()
        
        // Listen for ad blocker setting changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adBlockerSettingsDidChange),
            name: .adBlockerSettingsDidChange,
            object: nil
        )
    }
    
    private func setupWebView() {
        // Configure WebKit
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default() // Persistent cookies/storage
        
        // Apply ad blocker if enabled
        if SettingsStore.shared.settings.enableAdBlocker {
            print("🛡️ Ad blocker enabled, applying content rules...")
            ContentBlocker.shared.applyRules(to: config) { [weak self] success in
                if success {
                    print("✅ Ad blocker active")
                } else {
                    print("⚠️ Ad blocker failed to initialize")
                }
                // Create webview after rules are applied (or failed)
                self?.createWebView(with: config)
            }
        } else {
            print("🔓 Ad blocker disabled")
            // Create webview immediately if ad blocker is disabled
            createWebView(with: config)
        }
    }
    
    private func createWebView(with config: WKWebViewConfiguration) {
        // Create webview - leave room for title bar at top
        var webViewFrame = view.bounds
        webViewFrame.size.height -= Constants.titleBarHeight
        webView = WKWebView(frame: webViewFrame, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true
        webView.autoresizingMask = [.width, .height]
        
        view.addSubview(webView)
        
        // Update title when page loads
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        // Now that webView exists, restore zoom and setup floating button
        restoreZoomLevel()
        setupFloatingButton()
        
        // Load initial URL if we have one
        if let url = initialURL {
            webView.load(URLRequest(url: url))
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            titleBarView?.updateTitle(webView.title ?? "")
        }
    }
    
    deinit {
        // Remove KVO observer
        webView?.removeObserver(self, forKeyPath: "title")
        
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupFloatingButton() {
        // Only show if enabled in settings
        guard SettingsStore.shared.settings.showFloatingButton else {
            return
        }
        
        let browserName = SettingsStore.shared.settings.mainBrowserName
        let button = FloatingButton(action: { [weak self] in
            self?.openInMainBrowser()
        }, browserName: browserName)
        
        let hostingView = NSHostingView(rootView: button)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(hostingView)
        
        // Position in top-right corner (button sizes itself, doesn't constrain window)
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.widthAnchor.constraint(equalToConstant: 200),
            hostingView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        floatingButtonHost = hostingView
    }
    
    func updateFloatingButtonVisibility() {
        if SettingsStore.shared.settings.showFloatingButton {
            if floatingButtonHost == nil {
                setupFloatingButton()
            }
        } else {
            floatingButtonHost?.removeFromSuperview()
            floatingButtonHost = nil
        }
    }
    
    @objc func adBlockerSettingsDidChange() {
        // Content rules are baked into WKWebViewConfiguration at creation time,
        // so we need to recreate the webview to apply/remove them
        print("🔄 Ad blocker settings changed, recreating webview...")
        recreateWebView()
    }
    
    private func recreateWebView() {
        // Save current URL to restore after recreation
        let currentURL = webView.url
        
        // Remove old webview
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeFromSuperview()
        webView = nil
        
        // Remove floating button (will be recreated with new webview)
        floatingButtonHost?.removeFromSuperview()
        floatingButtonHost = nil
        
        // Set initialURL to current page so it loads after recreation
        initialURL = currentURL
        
        // Recreate webview with new configuration
        setupWebView()
    }
    
    // MARK: - Actions
    
    @objc func copyCurrentURL() {
        guard let currentURL = webView.url else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(currentURL.absoluteString, forType: .string)
        
        print("📋 Copied URL to clipboard: \(currentURL.absoluteString)")
    }
    
    @objc func openInMainBrowser() {
        guard let currentURL = webView.url else { return }
        
        let browserURL = SettingsStore.shared.settings.mainBrowserAppURL
        
        BrowserOpener.openURL(currentURL, inBrowser: browserURL) { [weak self] success in
            if success && SettingsStore.shared.settings.closeAfterOpen {
                DispatchQueue.main.async {
                    self?.onRequestClose?()
                }
            }
        }
    }
    
    @objc func reload() {
        webView.reload()
    }
    
    @objc func goBack() {
        webView.goBack()
    }
    
    @objc func goForward() {
        webView.goForward()
    }
    
    @objc func closeWindow() {
        onRequestClose?()
    }
    
    @objc func zoomIn() {
        let currentZoom = webView.pageZoom
        webView.pageZoom = min(currentZoom + 0.1, 3.0)  // Max 300%
        saveZoomLevel()
    }
    
    @objc func zoomOut() {
        let currentZoom = webView.pageZoom
        webView.pageZoom = max(currentZoom - 0.1, 0.5)  // Min 50%
        saveZoomLevel()
    }
    
    @objc func resetZoom() {
        webView.pageZoom = 1.0
        saveZoomLevel()
    }
    
    // MARK: - Zoom Level Persistence
    
    private func restoreZoomLevel() {
        let defaults = UserDefaults.standard
        if let zoomValue = defaults.value(forKey: "MonoscopeZoomLevel") as? CGFloat,
           zoomValue >= 0.5 && zoomValue <= 3.0 { // Sanity check
            webView.pageZoom = zoomValue
            print("🔍 Restored zoom level: \(Int(zoomValue * 100))%")
        } else {
            print("🔍 Using default zoom level: 100%")
        }
    }
    
    private func saveZoomLevel() {
        let zoomValue = webView.pageZoom
        if zoomValue >= 0.5 && zoomValue <= 3.0 { // Sanity check
            let defaults = UserDefaults.standard
            defaults.set(zoomValue, forKey: "MonoscopeZoomLevel")
            print("💾 Saved zoom level: \(Int(zoomValue * 100))%")
        }
    }
    
    // MARK: - Keyboard Handling
    
    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // Shift+Command key combinations
        if flags == [.shift, .command] {
            switch event.charactersIgnoringModifiers?.lowercased() {
            case "c":  // Shift+Cmd+C (copy current URL)
                copyCurrentURL()
                return
            default:
                break
            }
        }
        
        // Command key combinations
        if flags == .command {
            switch event.charactersIgnoringModifiers {
            case "o":
                openInMainBrowser()
                return
            case "w":
                closeWindow()
                return
            case "r":
                reload()
                return
            case "[":
                goBack()
                return
            case "]":
                goForward()
                return
            case "+", "=":  // Cmd++ or Cmd+=
                zoomIn()
                return
            case "-", "_":  // Cmd+- or Cmd+_
                zoomOut()
                return
            case "0":  // Cmd+0
                resetZoom()
                return
            case "c":  // Cmd+C (copy selected text)
                NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self)
                return
            case "x":  // Cmd+X (cut)
                NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self)
                return
            case "v":  // Cmd+V (paste)
                NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self)
                return
            case "a":  // Cmd+A (select all)
                NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: self)
                return
            default:
                break
            }
        }
        
        // Escape key (keyCode 53)
        if event.keyCode == 53 && SettingsStore.shared.settings.escClosesWindow {
            closeWindow()
            return
        }
        
        super.keyDown(with: event)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        let scheme = url.scheme?.lowercased() ?? ""
        
        // Allow http and https
        if scheme == "http" || scheme == "https" {
            decisionHandler(.allow)
            return
        }
        
        // Allow special internal URLs (about:blank, data:, blob:, javascript:)
        if scheme == "about" || scheme == "data" || scheme == "blob" || scheme == "javascript" {
            decisionHandler(.allow)
            return
        }
        
        // For external schemes (mailto:, tel:, etc.), forward to system
        // Only forward schemes that make sense to open externally
        let externalSchemes = ["mailto", "tel", "sms", "facetime", "maps"]
        if externalSchemes.contains(scheme) {
            print("📤 Forwarding external URL to system: \(url)")
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        
        // Unknown scheme - cancel to be safe
        print("⚠️ Blocked unknown URL scheme: \(scheme)://")
        decisionHandler(.cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Could update UI here (e.g., show page title)
        print("✅ Page loaded successfully: \(webView.url?.absoluteString ?? "unknown")")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Don't show error page for cancelled navigations (error -999)
        // This happens when navigating away before a page finishes loading
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            print("⏭️ Navigation cancelled (normal behavior)")
            return
        }
        
        print("❌ Navigation failed: \(error.localizedDescription)")
        showErrorPage(error: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Don't show error page for cancelled navigations (error -999)
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            print("⏭️ Provisional navigation cancelled (normal behavior)")
            return
        }
        
        print("❌ Provisional navigation failed: \(error.localizedDescription)")
        showErrorPage(error: error)
    }
    
    private func showErrorPage(error: Error) {
        let errorHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro', sans-serif;
                    background: #1a1a1a;
                    color: #ffffff;
                    padding: 60px 40px;
                    margin: 0;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    min-height: 100vh;
                }
                .container {
                    max-width: 600px;
                    text-align: center;
                }
                h1 {
                    font-size: 48px;
                    font-weight: 600;
                    margin: 0 0 20px 0;
                }
                p {
                    font-size: 18px;
                    line-height: 1.6;
                    color: #999;
                    margin: 0 0 30px 0;
                }
                .error-details {
                    background: #2a2a2a;
                    border-radius: 12px;
                    padding: 20px;
                    margin-top: 30px;
                    text-align: left;
                }
                .error-details code {
                    color: #ff6b6b;
                    font-size: 14px;
                    word-break: break-all;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Can't Open Page</h1>
                <p>Monoscope couldn't load this page.</p>
                <div class="error-details">
                    <code>\(error.localizedDescription)</code>
                </div>
            </div>
        </body>
        </html>
        """
        webView.loadHTMLString(errorHTML, baseURL: nil)
    }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {
    
    // Prevent new windows/tabs - load in same webview instead
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        // Handle target="_blank" and window.open() by navigating in same window
        if let url = navigationAction.request.url {
            print("🔗 Intercepted new window request, loading in same window: \(url)")
            webView.load(URLRequest(url: url))
        }
        
        // Return nil to prevent new window creation
        return nil
    }
    
    // Handle JavaScript alerts
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alert = NSAlert()
        alert.messageText = "Alert"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
        completionHandler()
    }
    
    // Handle JavaScript confirms
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alert = NSAlert()
        alert.messageText = "Confirm"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        completionHandler(response == .alertFirstButtonReturn)
    }
    
    // Disable credential storage requests (no keychain prompts)
    func webView(_ webView: WKWebView,
                 respondTo challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Deny all credential storage requests
        completionHandler(.performDefaultHandling, nil)
    }
}

// MARK: - Title Bar View

class TitleBarView: NSView {
    private var titleLabel: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.15, alpha: 0.95).cgColor
        
        // Create title label
        titleLabel = NSTextField(labelWithString: "")
        titleLabel.textColor = NSColor.lightGray
        titleLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel.alignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Prevent label from affecting window size
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        addSubview(titleLabel)
        
        // Center the label with padding
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
    
    func updateTitle(_ title: String) {
        titleLabel.stringValue = title
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
