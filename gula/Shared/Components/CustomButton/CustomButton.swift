//
//  CustomButton.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 4/7/24.
//

import SwiftUI

struct CustomButton: View {
    @Binding var buttonState: ButtonState
    let type: ButtonType
    let height: CGFloat = 48
    let buttonText: LocalizedStringKey
    var backgroundColor: Color?
    var foregroundColor: Color?
    let action: () -> Void

    @State private var isPressed = false
    @State private var isHovered = false

    var body: some View {
        Button {
            action()
        } label: {
            switch buttonState {
            case .loading:
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(backgroundView)
            default:
                Text(buttonText)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .foregroundColor(foregroundColor ?? type.foregroundColor)
                    .background(backgroundView)
            }
        }
        .cornerRadius(8)
        .disabled(buttonState != .normal)
        .opacity(buttonState == .hide ? 0.6 : 1.0)
        .buttonStyle(.plain)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
        .scaleEffect(isPressed ? 0.96 : (isHovered ? 1.02 : 1.0))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering && buttonState == .normal
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
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let backgroundColor = backgroundColor {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: type.gradientColors.map { isHovered && buttonState == .normal ? $0 : $0.opacity(0.9) },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }

    private var shadowColor: Color {
        if let backgroundColor = backgroundColor {
            return backgroundColor.opacity(0.3)
        }
        return type.gradientColors.first?.opacity(0.3) ?? .clear
    }

    private var shadowRadius: CGFloat {
        isHovered && buttonState == .normal ? 12 : 6
    }

    private var shadowOffset: CGFloat {
        isHovered && buttonState == .normal ? 4 : 2
    }
}
