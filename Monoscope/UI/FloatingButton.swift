//
//  FloatingButton.swift
//  Monoscope
//
//  Floating "Open" button overlay with backdrop blur
//

import SwiftUI

struct FloatingButton: View {
    let action: () -> Void
    let browserName: String?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: action) {
                    Label(buttonTitle, systemImage: "arrow.up.forward.app")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(GlassButtonStyle())
                .padding(.top, 24)
                .padding(.trailing, 16)
            }
            Spacer()
        }
    }
    
    private var buttonTitle: String {
        if let browserName = browserName {
            return "Open in \(browserName)"
        } else {
            return "Open"
        }
    }
}

struct FloatingButton_Previews: PreviewProvider {
    static var previews: some View {
        FloatingButton(action: {
            print("Open tapped")
        }, browserName: "Chrome")
        .frame(width: 400, height: 300)
    }
}
