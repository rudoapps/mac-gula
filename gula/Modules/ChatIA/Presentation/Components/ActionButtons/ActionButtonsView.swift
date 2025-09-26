//
//  ActionButtonsView.swift
//
//
//  Created by Claude on 25/9/24.
//

import SwiftUI

struct ActionButtonsView: View {
    let actions: [ProjectAction]
    let onActionTap: (ProjectAction) -> Void
    let isExecuting: Bool

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones Disponibles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(actions, id: \.id) { action in
                    ActionButton(
                        action: action,
                        onTap: { onActionTap(action) },
                        isDisabled: isExecuting
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary, lineWidth: 1)
                )
        )
    }
}

private struct ActionButton: View {
    let action: ProjectAction
    let onTap: () -> Void
    let isDisabled: Bool

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: action.type.systemImage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isDisabled ? .secondary : .accentColor)

                Text(action.type.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isDisabled ? .secondary : .primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .help(action.description)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }

    private var backgroundColor: Color {
        if isDisabled {
            return Color.primary.opacity(0.1)
        } else {
            return Color.primary.opacity(0.05)
        }
    }

    private var borderColor: Color {
        if isDisabled {
            return Color.clear
        } else {
            return Color.primary.opacity(0.2)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ActionButtonsView(
            actions: [
                ProjectAction(type: .analyzeCode, description: "Analizar todo el código del proyecto"),
                ProjectAction(type: .runBuild, description: "Compilar el proyecto completo"),
                ProjectAction(type: .runTests, description: "Ejecutar toda la suite de tests"),
                ProjectAction(type: .generateModule, description: "Generar un nuevo módulo"),
                ProjectAction(type: .updateDependencies, description: "Actualizar dependencias del proyecto"),
                ProjectAction(type: .gitCommit, description: "Hacer commit de cambios pendientes")
            ],
            onActionTap: { action in
                print("Tapped: \(action.type.displayName)")
            },
            isExecuting: false
        )

        Text("Estado con acciones deshabilitadas:")
            .font(.headline)

        ActionButtonsView(
            actions: [
                ProjectAction(type: .analyzeCode, description: "Analizar código"),
                ProjectAction(type: .runBuild, description: "Compilar proyecto")
            ],
            onActionTap: { _ in },
            isExecuting: true
        )
    }
    .padding()
    .background(.ultraThinMaterial)
}