//
//  SettingsStore.swift
//  Monoscope
//
//  Manages app settings persistence via UserDefaults
//

import Foundation
import Combine

struct AppSettings: Codable {
    var mainBrowserAppURL: URL?
    var mainBrowserName: String?
    var showFloatingButton: Bool = true
    var closeAfterOpen: Bool = false
    var escClosesWindow: Bool = true
    var alwaysOnTop: Bool = false
    var nonActivatingWindows: Bool = true
    var hasSeenWelcome: Bool = false
    var enableAdBlocker: Bool = true  // Enabled by default for privacy
    var strictAdBlocking: Bool = false  // Block APM, chat widgets, feature flags (off by default)
}

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    @Published var settings: AppSettings {
        didSet {
            save()
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: Constants.UserDefaultsKeys.settings),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = AppSettings()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: Constants.UserDefaultsKeys.settings)
        }
    }
    
    func hasSeenWelcome() -> Bool {
        return settings.hasSeenWelcome
    }
    
    func markWelcomeSeen() {
        settings.hasSeenWelcome = true
    }
}
