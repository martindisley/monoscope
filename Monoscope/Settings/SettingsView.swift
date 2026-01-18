//
//  SettingsView.swift
//  Monoscope
//
//  SwiftUI settings interface
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var store = SettingsStore.shared
    @State private var browsers: [BrowserInfo] = []
    @State private var selectedBrowser: String?
    
    var body: some View {
        Form {
            Section("Main Browser") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("When you press Cmd+O, open links in:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Browser:", selection: $selectedBrowser) {
                        Text("Safari (default)").tag(nil as String?)
                        
                        ForEach(browsers) { browser in
                            HStack {
                                if let icon = browser.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                Text(browser.name)
                            }
                            .tag(browser.appURL.path as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            Section("Appearance") {
                Toggle("Show floating Open button", isOn: $store.settings.showFloatingButton)
                    .help("Display a floating button in the top-right corner to open links in your main browser")
                
                Toggle("Always on top", isOn: $store.settings.alwaysOnTop)
                    .help("Keep Monoscope windows above other windows")
            }
            
            Section("Behavior") {
                Toggle("Close window after opening in main browser", isOn: $store.settings.closeAfterOpen)
                    .help("Automatically close the Monoscope window after pressing Cmd+O")
                
                Toggle("Esc key closes window", isOn: $store.settings.escClosesWindow)
                    .help("Press Escape to quickly close the current window")
            }
            
            Section {
                HStack {
                    Spacer()
                    Text("Monoscope v\(Constants.appVersion)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 550, height: 450)
        .onAppear {
            loadBrowsers()
        }
        .onChange(of: selectedBrowser) { newValue in
            if let path = newValue {
                store.settings.mainBrowserAppURL = URL(fileURLWithPath: path)
            } else {
                store.settings.mainBrowserAppURL = nil
            }
        }
        .onChange(of: store.settings.showFloatingButton) { _ in
            notifyWindowsToUpdateUI()
        }
        .onChange(of: store.settings.alwaysOnTop) { _ in
            notifyWindowsToUpdateWindowLevel()
        }
    }
    
    private func loadBrowsers() {
        browsers = BrowserDetector.findInstalledBrowsers()
        selectedBrowser = store.settings.mainBrowserAppURL?.path
    }
    
    private func notifyWindowsToUpdateUI() {
        // Post notification to update all open windows
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    private func notifyWindowsToUpdateWindowLevel() {
        NotificationCenter.default.post(name: .windowLevelDidChange, object: nil)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
    static let windowLevelDidChange = Notification.Name("windowLevelDidChange")
}

#Preview {
    SettingsView()
}
