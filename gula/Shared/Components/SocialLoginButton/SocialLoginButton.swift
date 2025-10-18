//
//  SocialLoginButton.swift
//  Gula
//
//  Created by Axel Pérez Gaspar on 27/8/24.
//

import SwiftUI

enum SocialButtonType {
    case apple, google

    var text: LocalizedStringKey {
        switch self {
        case .apple:
            "common_continueWithApple"
        case .google:
            "common_continueWithGoogle"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .apple:
                .white
        case .google:
                .black.opacity(0.5)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .apple:
                .black
        case .google:
                .white
        }
    }

    var image: Image {
        switch self {
        case .apple:
            Image(systemName: "applelogo")
        case .google:
            Image(.logoGoogle)
        }
    }
}

struct SocialLoginButton: View {
    let buttonType: SocialButtonType
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 12) {
                buttonType.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(buttonType.text)
                    .font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundStyle(buttonType.foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(buttonType.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                    )
            )
        })
        .buttonStyle(.plain)
        .shadow(
            color: Color.black.opacity(isHovered ? 0.1 : 0.05),
            radius: isHovered ? 8 : 4,
            x: 0,
            y: isHovered ? 3 : 2
        )
        .scaleEffect(isPressed ? 0.97 : (isHovered ? 1.02 : 1.0))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}
