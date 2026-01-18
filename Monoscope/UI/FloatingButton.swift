//
//  FloatingButton.swift
//  Monoscope
//
//  Floating "Open" button overlay with backdrop blur
//

import SwiftUI

struct FloatingButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: action) {
                    Label("Open", systemImage: "arrow.up.forward.app")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding(.top, 24)
                .padding(.trailing, 16)
            }
            Spacer()
        }
    }
}

#Preview {
    FloatingButton {
        print("Open tapped")
    }
    .frame(width: 400, height: 300)
}
