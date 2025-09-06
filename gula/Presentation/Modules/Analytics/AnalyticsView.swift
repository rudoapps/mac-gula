import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                OverviewCards(metrics: viewModel.metrics)
                ChartsSection(weekData: viewModel.weekData, weekDays: viewModel.weekDays)
                RecentMetrics(recentItems: viewModel.recentItems)
            }
            .padding()
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct OverviewCards: View {
    let metrics: [MetricCard]
    
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
    let weekData: [Int]
    let weekDays: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad Semanal")
                .font(.title2)
                .fontWeight(.semibold)
            
            WeeklyChart(weekData: weekData, weekDays: weekDays)
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
    let weekData: [Int]
    let weekDays: [String]
    
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
    let recentItems: [RecentMetric]
    
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

#Preview {
    AnalyticsView()
        .frame(width: 800, height: 600)
}