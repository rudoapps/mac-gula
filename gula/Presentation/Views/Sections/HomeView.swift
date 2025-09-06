import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeaderSection()
                StatsGrid()
                RecentActivity()
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
    }
}

struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("¡Bienvenido a Gula!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Tu espacio de trabajo personal")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
    }
}

struct StatsGrid: View {
    let stats = [
        StatItem(title: "Proyectos", value: "12", icon: "folder.fill", color: .blue),
        StatItem(title: "Documentos", value: "48", icon: "doc.fill", color: .green),
        StatItem(title: "Favoritos", value: "8", icon: "heart.fill", color: .red),
        StatItem(title: "Herramientas", value: "24", icon: "wrench.fill", color: .orange)
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(stats) { stat in
                StatCard(stat: stat)
            }
        }
    }
}

struct StatCard: View {
    let stat: StatItem
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: stat.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(stat.color)
            
            Text(stat.value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(stat.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
}

struct RecentActivity: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad Reciente")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(0..<5) { index in
                    ActivityRow(
                        title: "Documento modificado",
                        subtitle: "Proyecto \(index + 1).md",
                        time: "\(index + 1)h"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct StatItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

#Preview {
    HomeView()
        .frame(width: 800, height: 600)
}