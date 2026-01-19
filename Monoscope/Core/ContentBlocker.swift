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
    
    private let ruleListIdentifier = "MonoscopeAdBlocker"
    private var cachedRuleList: WKContentRuleList?
    
    private init() {}
    
    /// Applies content blocking rules to a WKWebViewConfiguration
    /// - Parameter configuration: The configuration to apply rules to
    /// - Parameter completion: Called when rules are applied or if an error occurs
    func applyRules(to configuration: WKWebViewConfiguration, completion: @escaping (Bool) -> Void) {
        // If we have cached rules, apply immediately
        if let ruleList = cachedRuleList {
            configuration.userContentController.add(ruleList)
            completion(true)
            return
        }
        
        // Try to load existing compiled rules
        WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: ruleListIdentifier) { [weak self] ruleList, error in
            guard let self = self else { return }
            
            if let ruleList = ruleList {
                // Rules already compiled, use them
                print("✅ Loaded cached content blocking rules")
                self.cachedRuleList = ruleList
                configuration.userContentController.add(ruleList)
                completion(true)
            } else {
                // Need to compile rules from JSON
                print("📦 Compiling content blocking rules...")
                self.compileRules { success in
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
    
    /// Compiles filter rules from bundled JSON into WKContentRuleList
    private func compileRules(completion: @escaping (Bool) -> Void) {
        // Load rules from bundled JSON file
        guard let rulesURL = Bundle.main.url(forResource: "filter-rules", withExtension: "json"),
              let rulesData = try? Data(contentsOf: rulesURL),
              let rulesJSON = String(data: rulesData, encoding: .utf8) else {
            print("❌ Failed to load filter-rules.json from bundle")
            completion(false)
            return
        }
        
        // Compile rules
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: ruleListIdentifier,
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
    
    /// Removes compiled rules (useful for updates)
    func clearCache(completion: @escaping (Bool) -> Void) {
        cachedRuleList = nil
        WKContentRuleListStore.default().removeContentRuleList(forIdentifier: self.ruleListIdentifier) { error in
            if let error = error {
                print("⚠️ Failed to clear content blocker cache: \(error.localizedDescription)")
                completion(false)
            } else {
                print("🗑️ Cleared content blocker cache")
                completion(true)
            }
        }
    }
    
    /// Recompiles rules from bundle (useful after updating filter-rules.json)
    func recompileRules(completion: @escaping (Bool) -> Void) {
        clearCache { [weak self] _ in
            self?.compileRules(completion: completion)
        }
    }
}
