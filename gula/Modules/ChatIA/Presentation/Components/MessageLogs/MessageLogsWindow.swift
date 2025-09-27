//
//  MessageLogsWindow.swift
//
//
//  Created by Claude on 25/9/24.
//

import SwiftUI

struct MessageLogsWindow: View {
    let logs: [ActionLog]
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Text("Logs del Mensaje")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Cerrar logs")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .overlay(alignment: .bottom) {
                Divider()
            }

            // Logs content
            if logs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("No hay logs disponibles")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(logs) { log in
                                MessageLogRow(log: log)
                                    .id(log.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onAppear {
                        // Auto-scroll to bottom
                        if let lastLog = logs.last {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    proxy.scrollTo(lastLog.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }

            // Footer with actions
            HStack {
                Button(action: copyAllLogs) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12, weight: .medium))
                        Text("Copiar")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .buttonStyle(.bordered)
                .disabled(logs.isEmpty)

                Button(action: exportLogs) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12, weight: .medium))
                        Text("Exportar")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .buttonStyle(.bordered)
                .disabled(logs.isEmpty)

                Spacer()

                Text("\(logs.count) entradas")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                Divider()
            }
        }
        .frame(width: 650, height: 450)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }

    private func copyAllLogs() {
        let logsText = logs.map { log in
            let timestamp = DateFormatter.logFormatter.string(from: log.timestamp)
            return "[\(timestamp)] \(log.level.rawValue): \(log.message)"
        }.joined(separator: "\n")

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(logsText, forType: .string)
    }

    private func exportLogs() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "message-logs-\(DateFormatter.fileNameFormatter.string(from: Date())).txt"
        savePanel.title = "Exportar Logs del Mensaje"

        if savePanel.runModal() == .OK, let url = savePanel.url {
            let logsText = logs.map { log in
                let timestamp = DateFormatter.logFormatter.string(from: log.timestamp)
                return "[\(timestamp)] \(log.level.rawValue): \(log.message)"
            }.joined(separator: "\n")

            try? logsText.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

private struct MessageLogRow: View {
    let log: ActionLog

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timestamp
            Text(timestamp)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 65, alignment: .leading)

            // Level indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(Color(log.level.color))
                    .frame(width: 6, height: 6)

                Text(log.level.rawValue)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(log.level.color))
                    .frame(width: 35, alignment: .leading)
            }

            // Message
            Text(log.message)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(logBackgroundColor)
        )
    }

    private var timestamp: String {
        DateFormatter.logFormatter.string(from: log.timestamp)
    }

    private var logBackgroundColor: Color {
        switch log.level {
        case .error: return Color.red.opacity(0.05)
        case .warning: return Color.orange.opacity(0.05)
        case .success: return Color.green.opacity(0.05)
        case .info: return Color.blue.opacity(0.03)
        case .debug: return Color.purple.opacity(0.03)
        }
    }
}

#Preview {
    MessageLogsWindow(
        logs: [
            ActionLog(level: .info, message: "🚀 Iniciando Ejecutar Build"),
            ActionLog(level: .debug, message: "Acción: Compilar proyecto iOS"),
            ActionLog(level: .info, message: "Preparando entorno de ejecución..."),
            ActionLog(level: .info, message: "Entorno preparado correctamente"),
            ActionLog(level: .info, message: "Iniciando ejecución..."),
            ActionLog(level: .info, message: "Compilando 47 archivos Swift..."),
            ActionLog(level: .warning, message: "Deprecated API usage in HomeView.swift:42"),
            ActionLog(level: .info, message: "Linking executable..."),
            ActionLog(level: .success, message: "✅ Ejecutar Build completado exitosamente"),
            ActionLog(level: .debug, message: "Output: Build succeeded in 12.3 seconds"),
            ActionLog(level: .success, message: "🎉 Acción completada en 2.1s"),
        ],
        onDismiss: { print("Dismiss logs") }
    )
    .padding(40)
    .background(.ultraThinMaterial)
}