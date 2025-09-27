//
//  MessageLogsButton.swift
//
//
//  Created by Claude on 25/9/24.
//

import SwiftUI

struct MessageLogsButton: View {
    let logs: [ActionLog]
    @State private var showingLogsWindow = false

    var body: some View {
        Button(action: {
            showingLogsWindow = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)

                Text("\(logs.count)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(showingLogsWindow ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showingLogsWindow)
        .sheet(isPresented: $showingLogsWindow) {
            MessageLogsWindow(
                logs: logs,
                onDismiss: {
                    showingLogsWindow = false
                }
            )
        }
    }
}

#Preview {
    MessageLogsButton(
        logs: [
            ActionLog(level: .info, message: "Iniciando compilación del proyecto iOS"),
            ActionLog(level: .success, message: "Build succeeded in 12.3 seconds"),
            ActionLog(level: .warning, message: "Deprecated API usage in HomeView.swift:42")
        ]
    )
    .padding()
}