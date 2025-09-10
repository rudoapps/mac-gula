import SwiftUI

struct TemplateFormView: View {
    @Binding var templateName: String
    @Binding var selectedTemplateType: TemplateType
    let onLoadTemplates: () -> Void
    let onGenerateTemplate: () -> Void
    let isGenerateDisabled: Bool
    
    var body: some View {
        ProfessionalFormContainer(
            title: "Generador de Templates",
            subtitle: "Genera estructuras completas de Clean Architecture",
            icon: "doc.text.image",
            gradientColors: [.purple, .pink]
        ) {
            VStack(alignment: .leading, spacing: 20) {
                // Template Name Input
                ProfessionalTextField(
                    title: "Nombre del Template",
                    placeholder: "ej: user, product, order",
                    icon: "textformat",
                    text: $templateName,
                    validation: { name in
                        if name.isEmpty {
                            return ProfessionalTextField.ValidationResult(isValid: false, message: nil)
                        } else if name.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
                            return ProfessionalTextField.ValidationResult(isValid: false, message: "Solo letras y números permitidos")
                        } else {
                            return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                        }
                    }
                )
                
                // Template Type Selection (Hidden for now)
                // TemplateTypeSelectionView(selectedTemplateType: $selectedTemplateType)
                
                // Action Buttons
                HStack(spacing: 16) {
                    ProfessionalButton(
                        title: "Cargar Templates",
                        icon: "square.grid.3x3.fill",
                        gradientColors: [.purple, .pink],
                        style: .outline,
                        isDisabled: false
                    ) {
                        onLoadTemplates()
                    }
                    
                    ProfessionalButton(
                        title: "Generar Template",
                        icon: "plus.app",
                        gradientColors: [.purple, .pink],
                        style: .primary,
                        isDisabled: isGenerateDisabled
                    ) {
                        onGenerateTemplate()
                    }
                }
            }
        }
    }
}

struct TemplateTypeSelectionView: View {
    @Binding var selectedTemplateType: TemplateType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Arquitectura")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(TemplateType.allCases, id: \.self) { type in
                    TemplateTypeCard(
                        type: type,
                        isSelected: selectedTemplateType == type
                    ) {
                        selectedTemplateType = type
                    }
                }
            }
        }
    }
}

struct TemplateTypeCard: View {
    let type: TemplateType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .purple)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .stroke(isSelected ? Color.purple : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}