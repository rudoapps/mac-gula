import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var autoSave = true
    @Published var showFileExtensions = false
    @Published var selectedTheme = "Sistema"
    @Published var useVibrancy = true
    @Published var enableNotifications = true
    @Published var soundEnabled = true
    
    let themes = ["Claro", "Oscuro", "Sistema"]
    
    func changeWorkingDirectory() {
        print("Changing working directory")
    }
    
    func clearCache() {
        print("Clearing cache")
    }
    
    func resetSettings() {
        autoSave = true
        showFileExtensions = false
        selectedTheme = "Sistema"
        useVibrancy = true
        enableNotifications = true
        soundEnabled = true
        print("Settings reset to defaults")
    }
    
    func showAbout() {
        print("Showing about dialog")
    }
}