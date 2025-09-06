import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                OverviewCards()
                ChartsSection()
                RecentMetrics()
            }
            .padding()
        }
    }
}

struct OverviewCards: View {
    let metrics = [
        MetricCard(title: "Documentos Creados", value: "156", change: "+12%", changeType: .positive, icon: "doc.text.fill", color: .blue),
        MetricCard(title: "Tiempo Activo", value: "48h", change: "+5%", changeType: .positive, icon: "clock.fill", color: .green),
        MetricCard(title: "Proyectos", value: "24", change: "0%", changeType: .neutral, icon: "folder.fill", color: .orange),
        MetricCard(title: "Colaboradores", value: "8", change: "+2", changeType: .positive, icon: "person.2.fill", color: .purple)
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(metrics) { metric in
                MetricCardView(metric: metric)
            }
        }
    }
}

struct MetricCardView: View {
    let metric: MetricCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: metric.icon)
                    .font(.title2)
                    .foregroundColor(metric.color)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: metric.changeType.icon)
                        .font(.caption)
                    Text(metric.change)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(metric.changeType.color)
            }
            
            Text(metric.value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(metric.title)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
}

struct ChartsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad Semanal")
                .font(.title2)
                .fontWeight(.semibold)
            
            WeeklyChart()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
    }
}

struct WeeklyChart: View {
    let weekData = [3, 7, 5, 8, 6, 9, 4]
    let weekDays = ["L", "M", "X", "J", "V", "S", "D"]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(.blue.gradient)
                            .frame(width: 30, height: CGFloat(value * 20))
                            .cornerRadius(4)
                        
                        Text(weekDays[index])
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 200)
            
            HStack {
                Text("Documentos por día")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Esta semana")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RecentMetrics: View {
    let recentItems = [
        RecentMetric(action: "Documento creado", item: "Informe Q3.docx", time: "Hace 2h"),
        RecentMetric(action: "Proyecto actualizado", item: "App Mobile", time: "Hace 4h"),
        RecentMetric(action: "Archivo compartido", item: "Presentación.pdf", time: "Hace 6h"),
        RecentMetric(action: "Comentario añadido", item: "Notas reunión", time: "Hace 8h"),
        RecentMetric(action: "Tarea completada", item: "Revisión código", time: "Hace 1d")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad Reciente")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(recentItems) { item in
                    RecentMetricRow(metric: item)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
    }
}

struct RecentMetricRow: View {
    let metric: RecentMetric
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(metric.action)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(metric.item)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(metric.time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MetricCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let change: String
    let changeType: ChangeType
    let icon: String
    let color: Color
}

struct RecentMetric: Identifiable {
    let id = UUID()
    let action: String
    let item: String
    let time: String
}

enum ChangeType {
    case positive, negative, neutral
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .secondary
        }
    }
    
    var icon: String {
        switch self {
        case .positive: return "arrow.up"
        case .negative: return "arrow.down"
        case .neutral: return "minus"
        }
    }
}

#Preview {
    AnalyticsView()
        .frame(width: 800, height: 600)
}