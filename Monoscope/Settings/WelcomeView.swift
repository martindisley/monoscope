//
//  WelcomeView.swift
//  Monoscope
//
//  First-launch welcome screen
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "scope")
                .font(.system(size: 72))
                .foregroundStyle(.blue.gradient)
                .padding(.top, 20)
            
            // Title
            VStack(spacing: 8) {
                Text("Welcome to Monoscope")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("A minimal browser for quick link previews")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "macwindow",
                    title: "Floating Windows",
                    description: "Opens links in clean, minimal windows"
                )
                
                FeatureRow(
                    icon: "keyboard",
                    title: "Keyboard First",
                    description: "Press Cmd+O to open in your main browser"
                )
                
                FeatureRow(
                    icon: "eye.slash",
                    title: "Distraction Free",
                    description: "Just web content, nothing else"
                )
            }
            .padding(.horizontal, 40)
            
            Divider()
                .padding(.vertical, 8)
            
            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("To set as your default browser:")
                    .font(.headline)
                
                InstructionStep(number: "1", text: "Open System Settings")
                InstructionStep(number: "2", text: "Go to Desktop & Dock")
                InstructionStep(number: "3", text: "Scroll to 'Default web browser'")
                InstructionStep(number: "4", text: "Select 'Monoscope'")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
            )
            .padding(.horizontal, 40)
            
            // Get Started Button
            Button(action: {
                SettingsStore.shared.markWelcomeSeen()
                dismiss()
            }) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .frame(width: 600, height: 650)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    WelcomeView()
}
