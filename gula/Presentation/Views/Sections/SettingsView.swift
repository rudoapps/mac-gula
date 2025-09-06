import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GeneralSettings()
                AppearanceSettings()
                NotificationSettings()
                AdvancedSettings()
            }
            .padding()
        }
    }
}

struct GeneralSettings: View {
    @State private var autoSave = true
    @State private var showFileExtensions = false
    
    var body: some View {
        SettingsSection(title: "General") {
            SettingsRow(icon: "folder.fill", title: "Directorio de trabajo", subtitle: "~/Documents/Gula") {
                Button("Cambiar") {
                    
                }
                .buttonStyle(.bordered)
            }
            
            SettingsToggle(icon: "square.and.arrow.down", title: "Guardar automáticamente", subtitle: "Guarda cambios automáticamente", isOn: $autoSave)
            
            SettingsToggle(icon: "doc.text", title: "Mostrar extensiones", subtitle: "Muestra extensiones de archivo", isOn: $showFileExtensions)
        }
    }
}

struct AppearanceSettings: View {
    @State private var selectedTheme = "Sistema"
    @State private var useVibrancy = true
    
    let themes = ["Claro", "Oscuro", "Sistema"]
    
    var body: some View {
        SettingsSection(title: "Apariencia") {
            SettingsRow(icon: "paintbrush.fill", title: "Tema", subtitle: "Apariencia de la aplicación") {
                Picker("Tema", selection: $selectedTheme) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme).tag(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)
            }
            
            SettingsToggle(icon: "sparkles", title: "Efectos de vibración", subtitle: "Usar efectos visuales semitransparentes", isOn: $useVibrancy)
        }
    }
}

struct NotificationSettings: View {
    @State private var enableNotifications = true
    @State private var soundEnabled = true
    
    var body: some View {
        SettingsSection(title: "Notificaciones") {
            SettingsToggle(icon: "bell.fill", title: "Activar notificaciones", subtitle: "Recibe notificaciones de la app", isOn: $enableNotifications)
            
            SettingsToggle(icon: "speaker.wave.2.fill", title: "Sonidos", subtitle: "Reproducir sonidos de notificación", isOn: $soundEnabled)
                .disabled(!enableNotifications)
        }
    }
}

struct AdvancedSettings: View {
    var body: some View {
        SettingsSection(title: "Avanzado") {
            SettingsRow(icon: "trash.fill", title: "Limpiar caché", subtitle: "Elimina archivos temporales") {
                Button("Limpiar") {
                    
                }
                .buttonStyle(.bordered)
            }
            
            SettingsRow(icon: "arrow.clockwise", title: "Restablecer configuración", subtitle: "Volver a valores predeterminados") {
                Button("Restablecer") {
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            
            SettingsRow(icon: "info.circle.fill", title: "Acerca de Gula", subtitle: "Versión 1.0.0") {
                Button("Más info") {
                    
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
            )
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String?
    @ViewBuilder let trailing: Trailing
    
    init(icon: String, title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            trailing
        }
        .padding(16)
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    var body: some View {
        SettingsRow(icon: icon, title: title, subtitle: subtitle) {
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
        }
    }
}

#Preview {
    SettingsView()
        .frame(width: 800, height: 600)
}