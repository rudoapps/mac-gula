import Foundation
import SwiftUI

// MARK: - Project Detail ViewModel

@Observable
class ProjectDetailViewModel {
    var isLoading = false
    var showingError = false
    var errorMessage = ""

    init() {
        // Initialize any default values or setup
    }
    
    func loadData() {
        // Load any initial data needed for the project detail view
        print("🏗️ ProjectDetailViewModel: loadData() called")
    }
    
    func handleError(_ error: Error) {
        showingError = true
        errorMessage = error.localizedDescription
        print("❌ ProjectDetailViewModel: Error - \(error.localizedDescription)")
    }
}