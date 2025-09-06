import Foundation
import SwiftUI

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