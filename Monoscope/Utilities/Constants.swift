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
    
    // Glass effect styling parameters
    enum GlassEffect {
        static let darkTintOpacity: Double = 0.05         // Dark overlay on material (lower = more translucent)
        static let gradientTopOpacity: Double = 0.25      // Shimmer gradient strength
        static let borderTopOpacity: Double = 0.7         // Bright edge highlight
        static let borderBottomOpacity: Double = 0.2      // Subtle bottom edge
        static let shadowRadius: CGFloat = 12             // Shadow blur radius
        static let shadowOpacity: Double = 0.5            // Shadow darkness
    }
}
