import Foundation
import AppKit

class FilePickerService {
    static let shared = FilePickerService()
    
    private init() {}
    
    @MainActor
    func selectProjectFolder() async -> String? {
        return await withCheckedContinuation { continuation in
            let openPanel = NSOpenPanel()
            openPanel.title = "Seleccionar Carpeta del Proyecto"
            openPanel.message = "Elige la carpeta que contiene tu proyecto"
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = false
            openPanel.allowsMultipleSelection = false
            openPanel.showsHiddenFiles = false
            
            // Set default directory to user's Documents or home
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            openPanel.directoryURL = documentsPath
            
            let response = openPanel.runModal()
            
            if response == .OK {
                continuation.resume(returning: openPanel.url?.path)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
    @MainActor
    func selectNewProjectLocation(suggestedName: String) async -> String? {
        return await withCheckedContinuation { continuation in
            let savePanel = NSSavePanel()
            savePanel.title = "Crear Nuevo Proyecto"
            savePanel.message = "Selecciona dónde crear el nuevo proyecto"
            savePanel.canCreateDirectories = true
            savePanel.nameFieldStringValue = suggestedName
            
            // Set default directory to user's Documents
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            savePanel.directoryURL = documentsPath
            
            let response = savePanel.runModal()
            
            if response == .OK {
                continuation.resume(returning: savePanel.url?.path)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}