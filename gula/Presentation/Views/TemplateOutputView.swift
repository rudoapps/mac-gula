import SwiftUI

struct TemplateOutputView: View {
    let templateOutput: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateOutputHeaderView()
            
            TemplateOutputContentView(output: templateOutput)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1.5)
                )
                .shadow(color: .purple.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .frame(maxHeight: 300)
        .scrollBounceBehavior(.basedOnSize)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct TemplateOutputHeaderView: View {
    var body: some View {
        Text("Resultado de Generación")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.purple)
    }
}

struct TemplateOutputContentView: View {
    let output: String
    
    var body: some View {
        ScrollView {
            Text(output)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}