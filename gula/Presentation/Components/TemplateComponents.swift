import SwiftUI

// MARK: - Template Card

struct TemplateCard: View {
    let template: Template
    let isSelected: Bool
    let selectedType: TemplateType
    let onSelect: () -> Void
    let onGenerate: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Template Header
            HStack(spacing: 12) {
                // Template Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? Color.purple : Color.secondary.opacity(0.6),
                                    isSelected ? Color.pink : Color.secondary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: (isSelected ? Color.purple : Color.secondary).opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: template.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(template.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.purple)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // Template Description
            Text(template.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Supported Types
            HStack {
                ForEach(template.supportedTypes.prefix(2), id: \.self) { type in
                    HStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.caption2)
                        Text(type.displayName)
                            .font(.caption2)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(type == selectedType ? Color.purple.opacity(0.2) : Color.secondary.opacity(0.1))
                    )
                    .foregroundColor(type == selectedType ? .purple : .secondary)
                }
                
                Spacer()
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button("Seleccionar") {
                    onSelect()
                }
                .font(.caption)
                .foregroundColor(isSelected ? .white : .purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.purple.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                        .stroke(Color.purple, lineWidth: isSelected ? 0 : 1)
                )
                
                Button("Generar") {
                    onGenerate()
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                )
                
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected 
                            ? LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.secondary.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}