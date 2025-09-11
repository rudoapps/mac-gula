import SwiftUI

// MARK: - Professional Button

struct ProfessionalButton: View {
    let title: String
    let icon: String?
    let gradientColors: [Color]
    let action: () -> Void
    let isDisabled: Bool
    let style: ButtonStyle
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
    }
    
    init(
        title: String,
        icon: String? = nil,
        gradientColors: [Color] = [.blue, .cyan],
        style: ButtonStyle = .primary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradientColors = gradientColors
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundView)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .scaleEffect(isPressed ? 0.96 : (isHovered ? 1.02 : 1.0))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering && !isDisabled
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
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { isHovered ? $0 : $0.opacity(0.9) },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        case .secondary:
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        case .outline:
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isHovered ? gradientColors.first?.opacity(0.05) ?? .clear : .clear)
                )
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .outline:
            return .primary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return gradientColors.first?.opacity(0.3) ?? .clear
        case .secondary, .outline:
            return .black.opacity(0.06)
        }
    }
    
    private var shadowRadius: CGFloat {
        isHovered ? 12 : 6
    }
    
    private var shadowOffset: CGFloat {
        isHovered ? 4 : 2
    }
}

// MARK: - Press Events Extension

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}