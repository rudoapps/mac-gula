import SwiftUI

struct ToolsView: View {
    @State private var viewModel = ToolsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(viewModel.tools) { tool in
                    ToolCard(
                        tool: tool,
                        onUse: { viewModel.useTool(tool) }
                    )
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadTools()
        }
    }
}

struct ToolCard: View {
    let tool: Tool
    let onUse: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: tool.icon)
                    .font(.system(size: 32))
                    .foregroundColor(tool.color)
                
                Text(tool.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(tool.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Spacer(minLength: 8)
            
            Button(action: onUse) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.caption)
                    Text("Usar")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHovered ? tool.color.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    ToolsView()
        .frame(width: 800, height: 600)
}