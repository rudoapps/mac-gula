import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            switch viewModel.dependencyStatus {
            case .checking:
                LoadingView()
            case .allInstalled:
                SuccessView {
                    viewModel.proceedToMainApp()
                }
            case .missingDependencies(let dependencies):
                DependenciesView(
                    dependencies: dependencies,
                    onInstall: viewModel.installDependency,
                    onRecheck: viewModel.recheckDependencies,
                    isInstalling: viewModel.isInstalling,
                    viewModel: viewModel
                )
            case .error(let message):
                ErrorView(message: message) {
                    viewModel.recheckDependencies()
                }
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
    let isInstalling: Bool
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Dependencias requeridas")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                ForEach(dependencies) { dependency in
                    DependencyCard(
                        dependency: dependency,
                        onInstall: { onInstall(dependency) },
                        isInstalling: isInstalling
                    )
                }
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Verificar de nuevo") {
                        onRecheck()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isInstalling)
                    
                    if dependencies.allSatisfy({ $0.name != "Homebrew" }) {
                        Button("Instalar Gula CLI") {
                            if let gulaDependency = dependencies.first(where: { $0.name == "Gula CLI" }) {
                                onInstall(gulaDependency)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isInstalling)
                    }
                }
                
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

struct DependencyCard: View {
    let dependency: SystemDependency
    let onInstall: () -> Void
    let isInstalling: Bool
    
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
            
            if dependency.name == "Homebrew" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Para instalar Homebrew:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("1. Abre Terminal")
                    Text("2. Pega este comando:")
                    
                    HStack {
                        Text(dependency.installCommand)
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(.regularMaterial)
                            .cornerRadius(6)
                        
                        Button("Copiar") {
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(dependency.installCommand, forType: .string)
                            #else
                            UIPasteboard.general.string = dependency.installCommand
                            #endif
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    Text("3. Presiona Enter y sigue las instrucciones")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            } else {
                Button(isInstalling ? "Instalando..." : "Instalar automáticamente") {
                    onInstall()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isInstalling)
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

#Preview {
    OnboardingView()
}