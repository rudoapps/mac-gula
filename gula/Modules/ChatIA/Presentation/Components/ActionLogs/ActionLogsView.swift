//
//  ActionLogsView.swift
//
//
//  Created by Claude on 25/9/24.
//

import SwiftUI

struct ActionLogsView: View {
    let logs: [ActionLog]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("Logs de ejecución")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(logs) { log in
                            ActionLogRow(log: log)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary.opacity(0.5))
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.tertiary, lineWidth: 0.5)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

private struct ActionLogRow: View {
    let log: ActionLog

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(timeStamp)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Image(systemName: log.level.systemImage)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(log.level.color))
                .frame(width: 12)

            Text(log.message)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundColor(.primary)
                .textSelection(.enabled)

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private var timeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: log.timestamp)
    }
}


// Extension to ChatViewModel for logging
extension ChatViewModel {
    func addLog(_ level: ActionLog.LogLevel, message: String) {
        let log = ActionLog(level: level, message: message)
        actionLogs.append(log)

        // Keep only last 50 logs to prevent memory issues
        if actionLogs.count > 50 {
            actionLogs.removeFirst(actionLogs.count - 50)
        }
    }

    func clearLogs() {
        actionLogs.removeAll()
    }
}

#Preview {
    ActionLogsView(
        logs: [
            ActionLog(level: .info, message: "Iniciando compilación del proyecto iOS"),
            ActionLog(level: .info, message: "Verificando dependencias de SwiftUI"),
            ActionLog(level: .success, message: "Dependencias verificadas correctamente"),
            ActionLog(level: .info, message: "Compilando 47 archivos Swift..."),
            ActionLog(level: .warning, message: "Deprecated API usage in HomeView.swift:42"),
            ActionLog(level: .info, message: "Linking executable..."),
            ActionLog(level: .success, message: "Build succeeded in 12.3 seconds"),
            ActionLog(level: .debug, message: "Output: /Users/project/build/Debug/MyApp.app"),
        ]
    )
    .padding()
    .background(.ultraThinMaterial)
}