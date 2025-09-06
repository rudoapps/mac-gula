import Foundation
import SwiftUI

class ToolsViewModel: ObservableObject {
    @Published var tools: [Tool] = []
    
    func loadTools() {
        tools = Tool.availableTools
    }
    
    func useTool(_ tool: Tool) {
        print("Using tool: \(tool.name)")
    }
}