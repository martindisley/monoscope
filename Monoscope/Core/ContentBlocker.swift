//
//  ContentBlocker.swift
//  Monoscope
//
//  Manages WKContentRuleList for native ad blocking
//

import Foundation
import WebKit

class ContentBlocker {
    static let shared = ContentBlocker()
    
    private var cachedRuleList: WKContentRuleList?
    private var cachedStrictRuleList: WKContentRuleList?
    
    private init() {}
    
    /// Applies content blocking rules to a WKWebViewConfiguration
    /// - Parameter configuration: The configuration to apply rules to
    /// - Parameter completion: Called when rules are applied or if an error occurs
    func applyRules(to configuration: WKWebViewConfiguration, completion: @escaping (Bool) -> Void) {
        let strictModeEnabled = SettingsStore.shared.settings.strictAdBlocking
        
        // Apply standard rules first
        applyStandardRules(to: configuration) { [weak self] standardSuccess in
            guard let self = self else {
                completion(standardSuccess)
                return
            }
            
            if strictModeEnabled {
                // Also apply strict rules
                self.applyStrictRules(to: configuration) { strictSuccess in
                    completion(standardSuccess) // Standard rules are the baseline
                }
            } else {
                completion(standardSuccess)
            }
        }
    }
    
    /// Applies standard content blocking rules
    private func applyStandardRules(to configuration: WKWebViewConfiguration, completion: @escaping (Bool) -> Void) {
        // If we have cached rules, apply immediately
        if let ruleList = cachedRuleList {
            configuration.userContentController.add(ruleList)
            completion(true)
            return
        }
        
        // Try to load existing compiled rules
        WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: Constants.AdBlocker.ruleListIdentifier) { [weak self] ruleList, error in
            guard let self = self else { return }
            
            if let ruleList = ruleList {
                // Rules already compiled, use them
                print("✅ Loaded cached content blocking rules")
                self.cachedRuleList = ruleList
                DispatchQueue.main.async {
                    configuration.userContentController.add(ruleList)
                    completion(true)
                }
            } else {
                // Need to compile rules from JSON
                print("📦 Compiling content blocking rules...")
                self.compileRules { success in
                    DispatchQueue.main.async {
                        if success, let ruleList = self.cachedRuleList {
                            configuration.userContentController.add(ruleList)
                            completion(true)
                        } else {
                            print("⚠️ Failed to compile content blocking rules")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    /// Compiles filter rules from bundled JSON into WKContentRuleList
    private func compileRules(completion: @escaping (Bool) -> Void) {
        // Load rules from bundled JSON file
        guard let rulesURL = Bundle.main.url(forResource: Constants.AdBlocker.filterRulesFilename, withExtension: Constants.AdBlocker.filterRulesExtension),
              let rulesData = try? Data(contentsOf: rulesURL),
              let rulesJSON = String(data: rulesData, encoding: .utf8) else {
            print("❌ Failed to load \(Constants.AdBlocker.filterRulesFilename).\(Constants.AdBlocker.filterRulesExtension) from bundle")
            completion(false)
            return
        }
        
        // Compile rules
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: Constants.AdBlocker.ruleListIdentifier,
            encodedContentRuleList: rulesJSON
        ) { [weak self] ruleList, error in
            if let error = error {
                print("❌ Failed to compile content rules: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let ruleList = ruleList {
                print("✅ Successfully compiled content blocking rules")
                self?.cachedRuleList = ruleList
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Applies strict content blocking rules (APM, chat widgets, feature flags, session replay)
    private func applyStrictRules(to configuration: WKWebViewConfiguration, completion: @escaping (Bool) -> Void) {
        // If we have cached strict rules, apply immediately
        if let ruleList = cachedStrictRuleList {
            configuration.userContentController.add(ruleList)
            completion(true)
            return
        }
        
        // Try to load existing compiled strict rules
        WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: Constants.AdBlocker.strictRuleListIdentifier) { [weak self] ruleList, error in
            guard let self = self else { return }
            
            if let ruleList = ruleList {
                // Rules already compiled, use them
                print("✅ Loaded cached strict content blocking rules")
                self.cachedStrictRuleList = ruleList
                DispatchQueue.main.async {
                    configuration.userContentController.add(ruleList)
                    completion(true)
                }
            } else {
                // Need to compile strict rules from JSON
                print("📦 Compiling strict content blocking rules...")
                self.compileStrictRules { success in
                    DispatchQueue.main.async {
                        if success, let ruleList = self.cachedStrictRuleList {
                            configuration.userContentController.add(ruleList)
                            completion(true)
                        } else {
                            print("⚠️ Failed to compile strict content blocking rules")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    /// Compiles strict filter rules from bundled JSON into WKContentRuleList
    private func compileStrictRules(completion: @escaping (Bool) -> Void) {
        // Load strict rules from bundled JSON file
        guard let rulesURL = Bundle.main.url(forResource: Constants.AdBlocker.filterRulesStrictFilename, withExtension: Constants.AdBlocker.filterRulesExtension),
              let rulesData = try? Data(contentsOf: rulesURL),
              let rulesJSON = String(data: rulesData, encoding: .utf8) else {
            print("❌ Failed to load \(Constants.AdBlocker.filterRulesStrictFilename).\(Constants.AdBlocker.filterRulesExtension) from bundle")
            completion(false)
            return
        }
        
        // Compile rules
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: Constants.AdBlocker.strictRuleListIdentifier,
            encodedContentRuleList: rulesJSON
        ) { [weak self] ruleList, error in
            if let error = error {
                print("❌ Failed to compile strict content rules: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let ruleList = ruleList {
                print("✅ Successfully compiled strict content blocking rules")
                self?.cachedStrictRuleList = ruleList
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Removes compiled rules (useful for updates)
    func clearCache(completion: @escaping (Bool) -> Void) {
        cachedRuleList = nil
        cachedStrictRuleList = nil
        
        guard let store = WKContentRuleListStore.default() else {
            completion(false)
            return
        }
        
        let group = DispatchGroup()
        var success = true
        
        // Clear standard rules
        group.enter()
        store.removeContentRuleList(forIdentifier: Constants.AdBlocker.ruleListIdentifier) { error in
            if let error = error {
                print("⚠️ Failed to clear content blocker cache: \(error.localizedDescription)")
                success = false
            } else {
                print("🗑️ Cleared content blocker cache")
            }
            group.leave()
        }
        
        // Clear strict rules
        group.enter()
        store.removeContentRuleList(forIdentifier: Constants.AdBlocker.strictRuleListIdentifier) { error in
            if let error = error {
                print("⚠️ Failed to clear strict content blocker cache: \(error.localizedDescription)")
                // Don't fail if strict rules weren't compiled
            } else {
                print("🗑️ Cleared strict content blocker cache")
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(success)
        }
    }
    
    /// Recompiles rules from bundle (useful after updating filter-rules.json)
    func recompileRules(completion: @escaping (Bool) -> Void) {
        clearCache { [weak self] _ in
            self?.compileRules(completion: completion)
        }
    }
}
