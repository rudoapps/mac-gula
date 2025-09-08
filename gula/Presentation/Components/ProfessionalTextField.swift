import SwiftUI

struct ProfessionalTextField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    let isSecure: Bool
    let isOptional: Bool
    let validation: ((String) -> ValidationResult)?
    
    @State private var isFocused = false
    @State private var isHovered = false
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case textField
    }
    
    struct ValidationResult {
        let isValid: Bool
        let message: String?
    }
    
    init(
        title: String,
        placeholder: String,
        icon: String,
        text: Binding<String>,
        isSecure: Bool = false,
        isOptional: Bool = false,
        validation: ((String) -> ValidationResult)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.isSecure = isSecure
        self.isOptional = isOptional
        self.validation = validation
    }
    
    private var validationResult: ValidationResult? {
        return validation?(text)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Simple label
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                if isOptional {
                    Text("(opcional)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                
                Spacer()
            }
            
            // Compact text field container
            HStack(spacing: 8) {
                // Small icon
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.6))
                    .frame(width: 16)
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                            .font(.system(size: 14))
                            .textFieldStyle(.plain)
                    } else {
                        TextField(placeholder, text: $text)
                            .font(.system(size: 14))
                            .textFieldStyle(.plain)
                    }
                }
                .focused($focusedField, equals: .textField)
                .onChange(of: focusedField) { _, newValue in
                    isFocused = newValue == .textField
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            // Simple validation message
            if let result = validationResult, !text.isEmpty, !result.isValid, let message = result.message {
                Text(message)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
    
    private var borderColor: Color {
        if let result = validationResult, !text.isEmpty, !result.isValid {
            return Color.red.opacity(0.6)
        } else if isFocused {
            return Color.accentColor.opacity(0.6)
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
}

