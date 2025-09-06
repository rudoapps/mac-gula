import SwiftUI

struct ToolsView: View {
    let tools = Tool.availableTools
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(tools) { tool in
                    ToolCard(tool: tool)
                }
            }
            .padding()
        }
    }
}

struct ToolCard: View {
    let tool: Tool
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
            
            Button(action: {
                
            }) {
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

struct Tool: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    let category: ToolCategory
}

enum ToolCategory {
    case productivity, development, design, utility
}

extension Tool {
    static let availableTools = [
        Tool(name: "Editor de Texto", description: "Editor avanzado con resaltado de sintaxis", icon: "doc.text.fill", color: .blue, category: .productivity),
        Tool(name: "Conversor PDF", description: "Convierte documentos a formato PDF", icon: "arrow.2.squarepath", color: .red, category: .utility),
        Tool(name: "Compresor Imágenes", description: "Reduce el tamaño de imágenes sin perder calidad", icon: "photo.fill", color: .green, category: .utility),
        Tool(name: "Generador QR", description: "Crea códigos QR personalizados", icon: "qrcode", color: .purple, category: .utility),
        Tool(name: "Color Picker", description: "Selecciona y guarda colores de la pantalla", icon: "eyedropper.full", color: .orange, category: .design),
        Tool(name: "Terminal", description: "Acceso completo a la línea de comandos", icon: "terminal.fill", color: .gray, category: .development),
        Tool(name: "Calculadora", description: "Calculadora científica avanzada", icon: "function", color: .cyan, category: .utility),
        Tool(name: "Notas Rápidas", description: "Toma notas rápidas y organízalas", icon: "note.text", color: .yellow, category: .productivity),
        Tool(name: "Captura Pantalla", description: "Herramientas avanzadas de captura", icon: "camera.viewfinder", color: .indigo, category: .utility),
        Tool(name: "Administrador Archivos", description: "Navegador avanzado de archivos", icon: "folder.fill", color: .teal, category: .utility),
        Tool(name: "Editor Código", description: "IDE ligero para desarrollo", icon: "chevron.left.forwardslash.chevron.right", color: .mint, category: .development),
        Tool(name: "Diseñador UI", description: "Herramientas básicas de diseño", icon: "rectangle.3.offgrid.fill", color: .pink, category: .design)
    ]
}

#Preview {
    ToolsView()
        .frame(width: 800, height: 600)
}