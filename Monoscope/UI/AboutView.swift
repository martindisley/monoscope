//
//  AboutView.swift
//  Monoscope
//
//  About window content
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(systemName: "scope")
                .font(.system(size: 64))
                .foregroundStyle(.blue.gradient)
            
            // App Name & Version
            VStack(spacing: 4) {
                Text("Monoscope")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version \(Constants.appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text("A minimal browser for quick link previews")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Divider()
                .padding(.vertical, 8)
            
            // Links
            VStack(spacing: 8) {
                Text("Made with ❤️ for focused browsing")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(40)
        .frame(width: 400, height: 350)
    }
}

#Preview {
    AboutView()
}
