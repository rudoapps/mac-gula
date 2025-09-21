import Foundation
import SwiftUI

@Observable
class ToolsViewModel {
    var tools: [Tool] = []
    
    func loadTools() {
        tools = Tool.availableTools
    }
    
    func useTool(_ tool: Tool) {
        print("Using tool: \(tool.name)")
    }
}