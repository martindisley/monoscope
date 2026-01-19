//
//  GlassButtonStyle.swift
//  Monoscope
//
//  Custom button style with liquid glass/glassmorphism effect
//

import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.primary)  // Let SwiftUI choose text color
            .padding(.horizontal, 20)   // Increased for pill shape aesthetics
            .padding(.vertical, 10)     // Adjusted for better proportions
            .background(
                ZStack {
                    // Layer 1: Base blur material
                    Capsule()
                        .fill(.ultraThinMaterial)
                    
                    // Layer 2: Dark tint overlay
                    Capsule()
                        .fill(Color.black.opacity(Constants.GlassEffect.darkTintOpacity))
                    
                    // Layer 3: Subtle gradient shimmer (light reflection simulation)
                    LinearGradient(
                        colors: [
                            Color.white.opacity(Constants.GlassEffect.gradientTopOpacity),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(Capsule())
                }
            )
            .overlay(
                // Edge lighting: bright top edge, subtle bottom edge
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(Constants.GlassEffect.borderTopOpacity),
                                Color.white.opacity(Constants.GlassEffect.borderBottomOpacity)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(Constants.GlassEffect.shadowOpacity),
                radius: Constants.GlassEffect.shadowRadius,
                x: 0,
                y: 2
            )
    }
}

// Preview for development
struct GlassButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Button(action: {}) {
                Label("Open", systemImage: "arrow.up.forward.app")
            }
            .buttonStyle(GlassButtonStyle())
            
            Button(action: {}) {
                Label("Open", systemImage: "arrow.up.forward.app")
            }
            .buttonStyle(GlassButtonStyle())
        }
        .frame(width: 400, height: 300)
        .background(Color.gray) // Test on different backgrounds
    }
}
