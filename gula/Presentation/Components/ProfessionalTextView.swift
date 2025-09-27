import SwiftUI

// Import ProjectAction if needed
// This might need to be adjusted based on your project structure

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
    @State private var textHeight: CGFloat = 0
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case textView
    }

    struct ValidationResult {
        let isValid: Bool
        let message: String?
    }

    let onSubmit: (() -> Void)?
    let suggestedActions: [ProjectAction]?
    let onActionTap: ((ProjectAction) -> Void)?
    let isExecutingAction: Bool

    init(
        title: String? = nil,
        placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        minHeight: CGFloat = 54,
        maxHeight: CGFloat = 120,
        isOptional: Bool = false,
        validation: ((String) -> ValidationResult)? = nil,
        onSubmit: (() -> Void)? = nil,
        suggestedActions: [ProjectAction]? = nil,
        onActionTap: ((ProjectAction) -> Void)? = nil,
        isExecutingAction: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.isOptional = isOptional
        self.validation = validation
        self.onSubmit = onSubmit
        self.suggestedActions = suggestedActions
        self.onActionTap = onActionTap
        self.isExecutingAction = isExecutingAction
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

            // Unified container with text field and actions
            VStack(spacing: 0) {
                // Text field area
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 8) {
                        // Optional icon
                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary.opacity(0.6))
                                .frame(width: 16)
                                .padding(.top, 4)
                        }

                        // Multi-line text editor without border
                        ZStack(alignment: .topLeading) {
                            // Placeholder text
                            if text.isEmpty {
                                Text(LocalizedStringKey(placeholder))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .padding(.horizontal, 4)
                                    .padding(.top, 0)
                                    .allowsHitTesting(false)
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
                                .onChange(of: text) { _, newValue in
                                    updateTextHeight(for: newValue)
                                }
                                .onKeyPress(keys: [.return]) { press in
                                    // Si se presiona Shift+Enter, permitir salto de línea
                                    if press.modifiers.contains(.shift) {
                                        return .ignored
                                    }

                                    // Si solo se presiona Enter y hay texto, enviar mensaje
                                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        onSubmit?()
                                        return .handled
                                    }

                                    return .ignored
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, text.isEmpty && suggestedActions?.isEmpty == false ? 8 : 12)
                }

                // Action buttons area
                if let actions = suggestedActions, !actions.isEmpty, text.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                            .foregroundColor(.primary.opacity(0.1))

                        HStack(spacing: 8) {
                            ForEach(actions.prefix(6), id: \.id) { action in
                                Button(action: {
                                    onActionTap?(action)
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: action.type.systemImage)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.accentColor)

                                        Text(action.type.displayName)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.primary.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.primary.opacity(0.15), lineWidth: 0.5)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isExecutingAction)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
            .frame(height: textHeight)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .onHover { hovering in
                isHovered = hovering
            }
            .onAppear {
                updateTextHeight(for: text)
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

    private func updateTextHeight(for text: String) {
        let lineHeight: CGFloat = 20
        let baseHeight: CGFloat = 40

        if text.isEmpty {
            // When empty, height includes space for actions if they exist
            let actionAreaHeight: CGFloat = (suggestedActions?.isEmpty == false) ? 50 : 0
            textHeight = baseHeight + actionAreaHeight
        } else {
            // Calculate number of lines
            let lines = text.components(separatedBy: .newlines).count
            let wrappedLines = max(1, lines)

            // Calculate height based on content (no actions when text exists)
            let calculatedHeight = baseHeight + (CGFloat(wrappedLines - 1) * lineHeight)
            textHeight = min(maxHeight, calculatedHeight)
        }
    }
}