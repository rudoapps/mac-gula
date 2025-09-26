//
//  ActionProgressView.swift
//
//
//  Created by Claude on 25/9/24.
//

import SwiftUI

struct ActionProgressView: View {
    let executingAction: ChatViewModel.ExecutingAction
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: executingAction.status.systemImage)
                    .foregroundColor(Color(executingAction.status.color))
                    .font(.system(size: 14, weight: .medium))

                Text(executingAction.action.type.displayName)
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                Text(executingAction.status.displayMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(executingAction.progressMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(y: 0.8)

                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(elapsedTime)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(executingAction.status.color).opacity(0.3), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: progress)
        .animation(.easeInOut(duration: 0.3), value: executingAction.status)
    }

    private var elapsedTime: String {
        let elapsed = Date().timeIntervalSince(executingAction.startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60

        if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ActionProgressView(
            executingAction: ChatViewModel.ExecutingAction(
                action: ProjectAction(type: .runBuild, description: "Compilando proyecto iOS"),
                status: .preparing,
                progressMessage: "Inicializando compilación...",
                startTime: Date().addingTimeInterval(-5)
            ),
            progress: 0.1
        )

        ActionProgressView(
            executingAction: ChatViewModel.ExecutingAction(
                action: ProjectAction(type: .runTests, description: "Ejecutando suite de tests"),
                status: .executing,
                progressMessage: "Ejecutando 15 tests...",
                startTime: Date().addingTimeInterval(-12)
            ),
            progress: 0.6
        )

        ActionProgressView(
            executingAction: ChatViewModel.ExecutingAction(
                action: ProjectAction(type: .generateModule, description: "Generando módulo LoginView"),
                status: .completed,
                progressMessage: "Módulo creado exitosamente",
                startTime: Date().addingTimeInterval(-8)
            ),
            progress: 1.0
        )

        ActionProgressView(
            executingAction: ChatViewModel.ExecutingAction(
                action: ProjectAction(type: .analyzeCode, description: "Analizando codebase"),
                status: .failed("No se pudo acceder al directorio"),
                progressMessage: "Error: Acceso denegado",
                startTime: Date().addingTimeInterval(-3)
            ),
            progress: 0.0
        )
    }
    .padding()
    .background(.ultraThinMaterial)
}