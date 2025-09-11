import SwiftUI

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let gradient: [Color]
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(isHovered ? 0.8 : 0.6) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: color.opacity(0.3), radius: isHovered ? 8 : 4, x: 0, y: 2)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: gradient.map { $0.opacity(isHovered ? 0.4 : 0.2) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isHovered ? 2 : 1
                )
        )
        .shadow(color: .black.opacity(0.06), radius: isHovered ? 12 : 6, x: 0, y: isHovered ? 6 : 3)
        .shadow(color: color.opacity(0.1), radius: isHovered ? 8 : 0, x: 0, y: 2)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}