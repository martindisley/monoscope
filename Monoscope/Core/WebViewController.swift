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
        setupFloatingButton()
        
        // Load initial URL
        if let url = initialURL {
            webView.load(URLRequest(url: url))
        }
    }
    
    private func setupWebView() {
        // Configure WebKit
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default() // Persistent cookies/storage
        
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
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            titleBarView?.updateTitle(webView.title ?? "")
        }
    }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: "title")
    }
    
    private func setupFloatingButton() {
        // Only show if enabled in settings
        guard SettingsStore.shared.settings.showFloatingButton else {
            return
        }
        
        let button = FloatingButton { [weak self] in
            self?.openInMainBrowser()
        }
        
        let hostingView = NSHostingView(rootView: button)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(hostingView)
        
        // Position in top-right corner (button sizes itself, doesn't constrain window)
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.widthAnchor.constraint(equalToConstant: 150),
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
    
    // MARK: - Actions
    
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
    
    // MARK: - Keyboard Handling
    
    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
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
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Navigation failed: \(error.localizedDescription)")
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

/// A compact title bar showing the page title
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
