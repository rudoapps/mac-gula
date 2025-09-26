//
//  InlineActionProgressView.swift
//
//
//  Created by Claude on 25/9/24.
//

import SwiftUI
import Combine

struct InlineActionProgressView: View {
    let executingAction: ChatViewModel.ExecutingAction
    let progress: Double

    @State private var animationProgress: Double = 0
    @State private var currentTime = Date()

    var body: some View {
        HStack(spacing: 10) {
            // Spinning icon
            Image(systemName: executingAction.status.systemImage)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(executingAction.status.color))
                .rotationEffect(.degrees(animationProgress * 360))
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: animationProgress)

            VStack(alignment: .leading, spacing: 2) {
                Text(executingAction.status.displayMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(timeElapsed)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)

                    if progress > 0 {
                        Text("(\(Int(progress * 100))%)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(executingAction.status.color))
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(executingAction.status.color).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color(executingAction.status.color).opacity(0.2), lineWidth: 0.5)
                )
        )
        .onAppear {
            animationProgress = 1.0
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
        }
    }

    private var timeElapsed: String {
        let elapsed = currentTime.timeIntervalSince(executingAction.startTime)
        return String(format: "%.1fs", elapsed)
    }
}

#Preview {
    VStack(spacing: 16) {
        InlineActionProgressView(
            executingAction: ChatViewModel.ExecutingAction(
                action: ProjectAction(type: .runBuild, description: "Compilar proyecto"),
                status: .executing,
                progressMessage: "Compilando proyecto...",
                startTime: Date().addingTimeInterval(-5)
            ),
            progress: 0.65
        )

        InlineActionProgressView(
            executingAction: ChatViewModel.ExecutingAction(
                action: ProjectAction(type: .runTests, description: "Ejecutar tests"),
                status: .preparing,
                progressMessage: "Preparando tests...",
                startTime: Date().addingTimeInterval(-2)
            ),
            progress: 0.2
        )
    }
    .padding()
    .background(.ultraThinMaterial)
}