import SwiftUI
import Foundation

struct TemplateGeneratorView: View {
    let project: Project
    @Bindable var projectManager: ProjectManager
    @State private var commandOutput: String = ""
    @State private var isLoading: Bool = false
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    @State private var templateName: String = ""
    @State private var generatedTemplates: [GulaTemplate] = []
    @State private var isLoadingTemplates: Bool = false
    @State private var showDebugOutput: Bool = false
    
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
                                } else if generatedTemplates.contains(where: { $0.name.lowercased() == name.lowercased() }) {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: "Ya existe un template con este nombre")
                                } else {
                                    return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                                }
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
                        
                        // Elegant Debug Toggle
                        if !commandOutput.isEmpty {
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    showDebugOutput.toggle()
                                }
                            }) {
                                HStack(spacing: 14) {
                                    // Animated Icon Container
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(
                                                colors: [.orange.opacity(0.1), .red.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: showDebugOutput ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.orange)
                                            .scaleEffect(showDebugOutput ? 1.1 : 1.0)
                                            .rotationEffect(.degrees(showDebugOutput ? 180 : 0))
                                    }
                                    
                                    // Content
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 8) {
                                            Text(showDebugOutput ? "Ocultar información debug" : "Ver información debug")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            // Animated Debug Badge
                                            Text("DEBUG")
                                                .font(.system(size: 9, weight: .black, design: .rounded))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(
                                                    Capsule()
                                                        .fill(LinearGradient(
                                                            colors: [.orange, .red],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        ))
                                                )
                                                .scaleEffect(showDebugOutput ? 1.05 : 0.95)
                                        }
                                        
                                        Text("Salida técnica del comando de generación")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Subtle Arrow
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.orange.opacity(0.6))
                                        .rotationEffect(.degrees(showDebugOutput ? 90 : 0))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.regularMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: showDebugOutput ? 
                                                            [.orange.opacity(0.4), .red.opacity(0.2)] :
                                                            [.orange.opacity(0.2), .clear],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: showDebugOutput ? 2 : 1
                                                )
                                        )
                                        .shadow(
                                            color: showDebugOutput ? .orange.opacity(0.2) : .clear,
                                            radius: showDebugOutput ? 8 : 0,
                                            x: 0,
                                            y: showDebugOutput ? 4 : 0
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(showDebugOutput ? 1.02 : 1.0)
                        }
                    }
                }
                
                // Enhanced Output Section (Debug Mode)
                if (!commandOutput.isEmpty || isLoading) && showDebugOutput {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 32, height: 32)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: "terminal")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text(isLoading ? "Generando Template..." : "Debug - Salida del Comando")
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
                                                colors: [.orange.opacity(0.4), .red.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: .orange.opacity(0.15), radius: 8, x: 0, y: 4)
                        .frame(maxHeight: 350)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Generated Templates Section
                ProfessionalFormContainer(
                    title: "Templates Generados",
                    subtitle: "\(generatedTemplates.count) template\(generatedTemplates.count == 1 ? "" : "s") creado\(generatedTemplates.count == 1 ? "" : "s") en este proyecto",
                    icon: "doc.text.below.ecg",
                    gradientColors: [.blue, .cyan]
                ) {
                    if isLoadingTemplates {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Cargando templates...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(minHeight: 80)
                    } else if generatedTemplates.isEmpty {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.blue.opacity(0.1), .cyan.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "doc.text.below.ecg")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(spacing: 8) {
                                Text("No hay templates generados")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Genera tu primer template usando el formulario de arriba")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(minHeight: 120)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(generatedTemplates) { template in
                                TemplateGeneratedCard(template: template)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 30)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            Task {
                await loadGeneratedTemplates()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func generateTemplate() async {
        isLoading = true
        
        // Hide debug output when starting a new generation
        showDebugOutput = false
        
        do {
            let result = try await projectManager.generateTemplate(templateName)
            commandOutput = result
            
            // Reload templates after successful generation
            await loadGeneratedTemplates()
            
            // Clear template name
            templateName = ""
            
            // Auto-show debug if there's an error in the output
            if result.lowercased().contains("error") || result.lowercased().contains("failed") {
                showDebugOutput = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
            // Show debug output when there's an error
            showDebugOutput = true
        }
        isLoading = false
    }
    
    private func loadGeneratedTemplates() async {
        isLoadingTemplates = true
        do {
            let status = try await projectManager.getProjectStatus()
            await MainActor.run {
                generatedTemplates = status.generatedTemplates
            }
        } catch {
            print("❌ Error loading generated templates: \(error)")
            // Keep current state on error
        }
        isLoadingTemplates = false
    }
}

// MARK: - Template Generated Card Component
struct TemplateGeneratedCard: View {
    let template: GulaTemplate
    
    var body: some View {
        HStack(spacing: 16) {
            // Template Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.1), .cyan.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                
                Image(systemName: platformIcon(for: template.platform))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            // Template Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(template.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(template.platform.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.blue.opacity(0.1))
                        )
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(template.generatedDate))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .cyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .blue.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform.lowercased() {
        case "ios":
            return "iphone"
        case "android":
            return "android"
        case "flutter":
            return "bird"
        case "python":
            return "snake"
        case "web":
            return "globe"
        default:
            return "doc.text"
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Fecha desconocida" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}