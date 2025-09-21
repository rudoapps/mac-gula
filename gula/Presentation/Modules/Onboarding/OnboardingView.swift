import SwiftUI

struct OnboardingView: View {
    @State var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            switch viewModel.dependencyStatus {
            case .checking:
                LoadingView()
            case .checkingConnectivity:
                LoadingView()
            case .noInternetConnection:
                ErrorView(message: "No hay conexión a Internet. Verifica tu conexión y vuelve a intentar.") {
                    viewModel.recheckDependencies()
                }
            case .allInstalled:
                SuccessView {
                    viewModel.proceedToMainApp()
                }
            case .missingDependencies(let dependencies):
                DependenciesView(
                    dependencies: dependencies,
                    onInstall: viewModel.installDependency,
                    onRecheck: viewModel.recheckDependencies,
                    viewModel: viewModel
                )
            case .error(let message):
                ErrorView(message: message) {
                    viewModel.recheckDependencies()
                }
            case .gulaUpdateRequired(let version):
                UpdateRequiredView(currentVersion: version)
            case .updatingGula:
                UpdatingView()
            case .gulaUpdated:
                UpdateCompletedView()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(
            colors: [.blue.opacity(0.1), .purple.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .onAppear {
            viewModel.checkDependencies()
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Configuración Inicial")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Necesitamos verificar que las dependencias estén instaladas")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Verificando dependencias...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
}

struct SuccessView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("¡Todo listo!")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Todas las dependencias están instaladas correctamente")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Continuar a la aplicación") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
}

struct DependenciesView: View {
    let dependencies: [SystemDependency]
    let onInstall: (SystemDependency) -> Void
    let onRecheck: () -> Void
    @Bindable var viewModel: OnboardingViewModel
    
    private var isAnyInstalling: Bool {
        return !viewModel.installingDependencies.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                Text("Dependencias requeridas")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if isAnyInstalling {
                    SmallSpinner()
                }
            }
            
            VStack(spacing: 16) {
                ForEach(dependencies) { dependency in
                    DependencyCard(
                        dependency: dependency,
                        onInstall: { onInstall(dependency) },
                        viewModel: viewModel
                    )
                    .opacity(viewModel.isInstalling(dependency.name) ? 0.7 : 1.0)
                    .scaleEffect(viewModel.isInstalling(dependency.name) ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isInstalling(dependency.name))
                }
            }
            
            VStack(spacing: 12) {
                Button("Verificar de nuevo") {
                    onRecheck()
                }
                .buttonStyle(.bordered)
                .disabled(isAnyInstalling)
                
                #if DEBUG
                Button("Saltar verificación (Debug)") {
                    // Simular que todas las dependencias están instaladas
                    viewModel.skipDependencyCheck()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
                #endif
            }
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
}

struct SmallSpinner: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                .frame(width: 16, height: 16)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 16, height: 16)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        }
    }
}

struct ProgressDots: View {
    @State private var animationState = 0
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 4, height: 4)
                    .scaleEffect(animationState == index ? 1.5 : 1.0)
                    .animation(.easeInOut(duration: 0.4), value: animationState)
            }
        }
        .onAppear {
            withAnimation {
                animationState = 0
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    animationState = (animationState + 1) % 3
                }
            }
        }
    }
}

struct InstallationIndicator: View {
    let progressMessage: String
    @State private var rotationAngle: Double = 0
    @State private var scale: Double = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    .frame(width: 20, height: 20)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(rotationAngle))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
            }
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Instalando...")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !progressMessage.isEmpty {
                    Text(progressMessage)
                        .font(.caption)
                        .opacity(0.7)
                        .animation(.easeInOut(duration: 0.3), value: progressMessage)
                    
                    // Dots de progreso animados
                    ProgressDots()
                        .padding(.top, 2)
                }
            }
        }
        .foregroundColor(.blue)
        .padding(.vertical, 8)
    }
}

struct DependencyCard: View {
    let dependency: SystemDependency
    let onInstall: () -> Void
    @Bindable var viewModel: OnboardingViewModel
    
    private var isHomebrewInstalled: Bool {
        switch viewModel.dependencyStatus {
        case .allInstalled:
            return true
        case .missingDependencies(let missing):
            return !missing.contains { $0.name == "Homebrew" }
        case .checking, .checkingConnectivity, .noInternetConnection, .error:
            return false
        case .gulaUpdateRequired, .updatingGula, .gulaUpdated:
            return true // If we're dealing with gula updates, homebrew is installed
        }
    }
    
    private var shouldDisableInstall: Bool {
        dependency.name == "Gula CLI" && !isHomebrewInstalled
    }
    
    private var isInstalling: Bool {
        return viewModel.isInstalling(dependency.name)
    }
    
    private var installationProgress: String {
        return viewModel.installationProgress(for: dependency.name)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: dependency.name == "Homebrew" ? "mug.fill" : "terminal")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dependency.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(dependency.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
            }
            
            if isInstalling {
                InstallationIndicator(progressMessage: installationProgress)
            } else {
                VStack(spacing: 8) {
                    Button(shouldDisableInstall ? "Instalar Homebrew primero" : "Instalar automáticamente") {
                        onInstall()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(shouldDisableInstall)
                    
                    if shouldDisableInstall {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.orange)
                            Text("Homebrew es requerido para instalar Gula CLI")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    }
                    
                    if dependency.name == "Homebrew" {
                        // Información adicional para Homebrew
                        VStack(alignment: .leading, spacing: 4) {
                            Text("O instalar manualmente:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(dependency.installCommand)
                                    .font(.system(.caption2, design: .monospaced))
                                    .padding(6)
                                    .background(.regularMaterial)
                                    .cornerRadius(4)
                                
                                Button("Copiar") {
                                    #if os(macOS)
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(dependency.installCommand, forType: .string)
                                    #else
                                    UIPasteboard.general.string = dependency.installCommand
                                    #endif
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            Text("Error de verificación")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Intentar de nuevo") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
}

struct UpdateRequiredView: View {
    let currentVersion: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Actualización requerida")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tu versión de Gula CLI (\(currentVersion)) necesita ser actualizada")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
}

struct UpdatingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Actualizando Gula CLI...")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Esto puede tardar unos minutos")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
}

struct UpdateCompletedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("¡Actualización completada!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Gula CLI ha sido actualizado exitosamente")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}