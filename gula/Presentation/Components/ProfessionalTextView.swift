import SwiftUI

struct ProfessionalTextView: View {
    let title: String?
    let placeholder: String
    let icon: String?
    @Binding var text: String
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let isOptional: Bool
    let validation: ((String) -> ValidationResult)?

    @State private var isFocused = false
    @State private var isHovered = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case textView
    }

    struct ValidationResult {
        let isValid: Bool
        let message: String?
    }

    init(
        title: String? = nil,
        placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        minHeight: CGFloat = 54,
        maxHeight: CGFloat = 120,
        isOptional: Bool = false,
        validation: ((String) -> ValidationResult)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.isOptional = isOptional
        self.validation = validation
    }

    private var validationResult: ValidationResult? {
        return validation?(text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Optional label
            if let title = title {
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
            }

            // Text view container
            HStack(alignment: .top, spacing: 8) {
                // Optional icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.6))
                        .frame(width: 16)
                        .padding(.top, 4)
                }

                // Multi-line text editor
                ZStack(alignment: .topLeading) {
                    // Placeholder text
                    if text.isEmpty {
                        Text(LocalizedStringKey(placeholder))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.7))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }

                    // Actual text editor
                    TextEditor(text: $text)
                        .font(.system(size: 14))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($focusedField, equals: .textView)
                        .onChange(of: focusedField) { _, newValue in
                            isFocused = newValue == .textView
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 1)
            )
            .onHover { hovering in
                isHovered = hovering
            }

            // Validation message
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
        } else if isHovered {
            return Color.secondary.opacity(0.5)
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
}