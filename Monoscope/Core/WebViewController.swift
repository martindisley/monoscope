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
        // Create the main container view
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Create webview
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true
        webView.autoresizingMask = [.width, .height]
        
        view.addSubview(webView)
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
        
        // Position in top-right corner
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        
        // For all other schemes (mailto:, tel:, custom apps), forward to system
        print("📤 Forwarding non-http(s) URL to system: \(url)")
        NSWorkspace.shared.open(url)
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
}
