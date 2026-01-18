//
//  Constants.swift
//  Monoscope
//
//  App-wide constants and configuration values
//

import Foundation
import AppKit

enum Constants {
    // Window defaults
    static let defaultWindowWidth: CGFloat = 900
    static let defaultWindowHeight: CGFloat = 600
    static let dragStripHeight: CGFloat = 20
    static let floatingButtonMargin: CGFloat = 16
    
    // App info
    static let appName = "Monoscope"
    static let appVersion = "1.0.0"
    
    // UserDefaults keys
    enum UserDefaultsKeys {
        static let hasSeenWelcome = "hasSeenWelcome"
        static let settings = "appSettings"
    }
    
    // Common browsers
    static let commonBrowsers: [(name: String, path: String)] = [
        ("Safari", "/Applications/Safari.app"),
        ("Google Chrome", "/Applications/Google Chrome.app"),
        ("Firefox", "/Applications/Firefox.app"),
        ("Arc", "/Applications/Arc.app"),
        ("Zen Browser", "/Applications/Zen Browser.app"),
        ("Brave Browser", "/Applications/Brave Browser.app"),
        ("Microsoft Edge", "/Applications/Microsoft Edge.app"),
        ("Opera", "/Applications/Opera.app"),
        ("Vivaldi", "/Applications/Vivaldi.app"),
    ]
}
