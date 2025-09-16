import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeaderSection()
                StatsGrid(stats: viewModel.stats, isLoading: false)
                RecentActivity(activities: viewModel.recentActivities)
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .onAppear {
            print("🏠 HomeView: onAppear ejecutado")
            viewModel.loadData()
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
    let stats: [StatItem]
    let isLoading: Bool
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(stats) { stat in
                StatCard(stat: stat, isLoading: isLoading)
            }
        }
    }
}

struct StatCard: View {
    let stat: StatItem
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isLoading && (stat.title.contains("Módulos") || stat.title.contains("Versión") || stat.title.contains("Estado")) {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(height: 32)
            } else {
                Image(systemName: stat.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(stat.color)
            }
            
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
    let activities: [ActivityItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad Reciente")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(activities) { activity in
                    ActivityRow(activity: activity)
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
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}





#Preview {
    HomeView()
        .frame(width: 800, height: 600)
}