import SwiftUI

// MARK: - Professional Form Container

struct ProfessionalFormContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    let gradientColors: [Color]
    @ViewBuilder let content: Content
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        gradientColors: [Color],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradientColors = gradientColors
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 28) {
            // Form Header
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 32)
            
            // Form Content
            content
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: gradientColors.map { $0.opacity(0.15) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 6)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                )
        }
    }
}