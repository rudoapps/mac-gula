import Foundation
import SwiftUI

@Observable
class SettingsViewModel {
    var autoSave = true
    var showFileExtensions = false
    var selectedTheme = "Sistema"
    var useVibrancy = true
    var enableNotifications = true
    var soundEnabled = true
    
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