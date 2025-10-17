//
//  AppFlowView.swift
//  Gula
//
//  Created by Claude Code
//

import SwiftUI

struct AppFlowView: View {
    @State private var isCheckingDependencies = true
    @State private var showOnboarding = false
    @State private var dependencyStatus: DependencyStatus = .checking
    @State private var projectManager = ProjectManager.shared

    private let dependenciesUseCase = CheckSystemDependenciesUseCase(systemRepository: SystemRepositoryImpl())

    var body: some View {
        VStack {
            if isCheckingDependencies {
                // Loading screen while checking dependencies
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)

                    Text(statusMessage)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    if case .gulaUpdateRequired(let version) = dependencyStatus {
                        Text("Versión actual: \(version)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
                .task {
                    await checkDependenciesOnStartup()
                }
            } else if showOnboarding {
                OnboardingBuilder.build {
                    showOnboarding = false
                }
                .frame(minWidth: 900, minHeight: 600)
            } else if projectManager.currentProject == nil {
                ProjectSelectionBuilder.build { project in
                    ProjectManager.shared.updateProjectAccessDate(project)
                }
                .frame(minWidth: 650, minHeight: 550)
            } else {
                MainContentView(project: projectManager.currentProject!) {
                    projectManager.currentProject = nil
                }
                .frame(minWidth: 900, minHeight: 600)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statusMessage: String {
        switch dependencyStatus {
        case .checking:
            return "Verificando dependencias..."
        case .checkingConnectivity:
            return "Verificando conexión a Internet..."
        case .noInternetConnection:
            return "Sin conexión a Internet"
        case .allInstalled:
            return "Dependencias verificadas ✅"
        case .missingDependencies(_):
            return "Instalando dependencias faltantes..."
        case .gulaUpdateRequired(_):
            return "Actualización de Gula requerida"
        case .updatingGula:
            return "Actualizando Gula...\nEsto puede tardar unos minutos"
        case .gulaUpdated:
            return "Gula actualizado exitosamente ✅"
        case .error(_):
            return "Error verificando dependencias"
        }
    }

    @MainActor
    private func checkDependenciesOnStartup() async {
        let finalStatus = await dependenciesUseCase.execute { status in
            Task { @MainActor in
                dependencyStatus = status
            }
        }

        switch finalStatus {
        case .allInstalled:
            isCheckingDependencies = false
            showOnboarding = false
        case .missingDependencies(_), .error(_), .checking, .checkingConnectivity, .noInternetConnection, .gulaUpdateRequired(_), .updatingGula, .gulaUpdated:
            isCheckingDependencies = false
            showOnboarding = true
        }
    }
}
