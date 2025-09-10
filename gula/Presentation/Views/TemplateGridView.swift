import SwiftUI

struct TemplateGridView: View {
    let availableTemplates: [Template]
    @Binding var selectedTemplate: Template?
    let selectedTemplateType: TemplateType
    let onSelectTemplate: (Template) -> Void
    let onGenerateTemplate: (Template) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Section Header
            TemplateGridHeaderView(templateCount: availableTemplates.count)
            
            // Templates by Category
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(availableTemplates) { template in
                    TemplateCard(
                        template: template,
                        isSelected: selectedTemplate == template,
                        selectedType: selectedTemplateType
                    ) {
                        selectedTemplate = template
                        onSelectTemplate(template)
                    } onGenerate: {
                        selectedTemplate = template
                        onGenerateTemplate(template)
                    }
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.15), Color.pink.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct TemplateGridHeaderView: View {
    let templateCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Templates Disponibles")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("\(templateCount) templates encontrados")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}