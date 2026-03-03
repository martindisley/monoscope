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
    static let defaultWindowWidth: CGFloat = 1400
    static let defaultWindowHeight: CGFloat = 900
    static let titleBarHeight: CGFloat = 32  // Compact title bar
    static let windowOffsetStep: CGFloat = 20
    static let floatingButtonMargin: CGFloat = 16
    
    // App info
    static let appName = "Monoscope"
    static let appVersion = "1.0.0"
    
    // UserDefaults keys
    enum UserDefaultsKeys {
        static let hasSeenWelcome = "hasSeenWelcome"
        static let settings = "appSettings"
    }
    
    // Ad Blocker
    enum AdBlocker {
        static let ruleListIdentifier = "MonoscopeAdBlocker"
        static let strictRuleListIdentifier = "MonoscopeAdBlockerStrict"
        static let filterRulesFilename = "filter-rules"
        static let filterRulesStrictFilename = "filter-rules-strict"
        static let filterRulesExtension = "json"
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
    
    // Glass effect styling parameters
    enum GlassEffect {
        static let darkTintOpacity: Double = 0.02         // Dark overlay on material (lower = more translucent)
        static let gradientTopOpacity: Double = 0.15      // Shimmer gradient strength
        static let borderTopOpacity: Double = 0.5         // Bright edge highlight
        static let borderBottomOpacity: Double = 0.15     // Subtle bottom edge
        static let shadowRadius: CGFloat = 12             // Shadow blur radius
        static let shadowOpacity: Double = 0.3            // Shadow darkness
    }
}
