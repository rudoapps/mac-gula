import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GeneralSettings(viewModel: viewModel)
                AppearanceSettings(viewModel: viewModel)
                NotificationSettings(viewModel: viewModel)
                AdvancedSettings(viewModel: viewModel)
            }
            .padding()
        }
    }
}

struct GeneralSettings: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsSection(title: "General") {
            SettingsRow(icon: "folder.fill", title: "Directorio de trabajo", subtitle: "~/Documents/Gula") {
                Button("Cambiar") {
                    viewModel.changeWorkingDirectory()
                }
                .buttonStyle(.bordered)
            }
            
            SettingsToggle(icon: "square.and.arrow.down", title: "Guardar automáticamente", subtitle: "Guarda cambios automáticamente", isOn: $viewModel.autoSave)
            
            SettingsToggle(icon: "doc.text", title: "Mostrar extensiones", subtitle: "Muestra extensiones de archivo", isOn: $viewModel.showFileExtensions)
        }
    }
}

struct AppearanceSettings: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsSection(title: "Apariencia") {
            SettingsRow(icon: "paintbrush.fill", title: "Tema", subtitle: "Apariencia de la aplicación") {
                Picker("Tema", selection: $viewModel.selectedTheme) {
                    ForEach(viewModel.themes, id: \.self) { theme in
                        Text(theme).tag(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)
            }
            
            SettingsToggle(icon: "sparkles", title: "Efectos de vibración", subtitle: "Usar efectos visuales semitransparentes", isOn: $viewModel.useVibrancy)
        }
    }
}

struct NotificationSettings: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsSection(title: "Notificaciones") {
            SettingsToggle(icon: "bell.fill", title: "Activar notificaciones", subtitle: "Recibe notificaciones de la app", isOn: $viewModel.enableNotifications)
            
            SettingsToggle(icon: "speaker.wave.2.fill", title: "Sonidos", subtitle: "Reproducir sonidos de notificación", isOn: $viewModel.soundEnabled)
                .disabled(!viewModel.enableNotifications)
        }
    }
}

struct AdvancedSettings: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsSection(title: "Avanzado") {
            SettingsRow(icon: "trash.fill", title: "Limpiar caché", subtitle: "Elimina archivos temporales") {
                Button("Limpiar") {
                    viewModel.clearCache()
                }
                .buttonStyle(.bordered)
            }
            
            SettingsRow(icon: "arrow.clockwise", title: "Restablecer configuración", subtitle: "Volver a valores predeterminados") {
                Button("Restablecer") {
                    viewModel.resetSettings()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            
            SettingsRow(icon: "info.circle.fill", title: "Acerca de Gula", subtitle: "Versión 1.0.0") {
                Button("Más info") {
                    viewModel.showAbout()
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