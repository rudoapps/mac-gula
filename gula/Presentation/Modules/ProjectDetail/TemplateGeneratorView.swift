import SwiftUI
import Foundation

struct TemplateGeneratorView: View {
    let project: Project
    @ObservedObject var projectManager: ProjectManager
    @State private var commandOutput: String = ""
    @State private var isLoading: Bool = false
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    @State private var templateName: String = ""
    @State private var templateType: String = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 40) {
                // Enhanced Professional Form Container
                ProfessionalFormContainer(
                    title: "Generador de Templates",
                    subtitle: "Automatiza la creación de código con plantillas inteligentes y personalizables",
                    icon: "wand.and.stars",
                    gradientColors: [.purple, .pink]
                ) {
                    VStack(spacing: 28) {
                        // Enhanced Template Name Input with validation
                        ProfessionalTextField(
                            title: "Nombre del Template",
                            placeholder: "user, car, product ...",
                            icon: "doc.text.fill",
                            text: $templateName,
                            validation: { name in
                                if name.isEmpty {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: nil)
                                } else if name.count < 2 {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: "El nombre debe tener al menos 2 caracteres")
                                } else if name.contains(" ") {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: "El nombre no puede contener espacios")
                                } else {
                                    return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                                }
                            }
                        )
                        
                        // Enhanced Template Type Input
                        ProfessionalTextField(
                            title: "Tipo de Template",
                            placeholder: "model, view, controller, service, component",
                            icon: "tag.circle.fill",
                            text: $templateType,
                            isOptional: true,
                            validation: { type in
                                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                            }
                        )
                        
                        // Enhanced Generate Button
                        HStack {
                            ProfessionalButton(
                                title: "Generar Template",
                                icon: "wand.and.stars.inverse",
                                gradientColors: [.purple, .pink],
                                style: .primary,
                                isDisabled: templateName.isEmpty
                            ) {
                                Task {
                                    await generateTemplate()
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Enhanced Output Section
                if !commandOutput.isEmpty || isLoading {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 32, height: 32)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text(isLoading ? "Generando Template..." : "Resultado de Generación")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        ScrollView(.vertical, showsIndicators: true) {
                            if isLoading {
                                VStack(spacing: 24) {
                                    // Animated generator icon
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 60, height: 60)
                                            .scaleEffect(isLoading ? 1.1 : 0.9)
                                            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isLoading)
                                        
                                        Image(systemName: "gearshape.2")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(isLoading ? 360 : 0))
                                            .animation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false), value: isLoading)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Generando Template...")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text("Ejecutando comando gula")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Animated progress bars
                                    VStack(spacing: 8) {
                                        ForEach(0..<3) { index in
                                            HStack {
                                                Text(["Preparando archivos...", "Generando código...", "Finalizando..."][index])
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Circle()
                                                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: 6, height: 6)
                                                    .scaleEffect(isLoading ? 1.5 : 0.5)
                                                    .opacity(isLoading ? 1.0 : 0.3)
                                                    .animation(
                                                        Animation.easeInOut(duration: 0.6)
                                                            .repeatForever()
                                                            .delay(Double(index) * 0.3),
                                                        value: isLoading
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                    
                                    Text("Por favor, espera mientras se genera el template")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.secondary.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .opacity(isLoading ? 0.7 : 1.0)
                                        .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isLoading)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            } else {
                                Text(commandOutput)
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(24)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.regularMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: .purple.opacity(0.1), radius: 8, x: 0, y: 4)
                        .frame(maxHeight: 350)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: 30)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func generateTemplate() async {
        isLoading = true
        do {
            let result = try await projectManager.generateTemplate(
                templateName,
                type: templateType.isEmpty ? nil : templateType
            )
            commandOutput = result
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
}