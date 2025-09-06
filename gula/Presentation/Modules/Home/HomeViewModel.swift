import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var stats: [StatItem] = []
    @Published var recentActivities: [ActivityItem] = []
    
    func loadData() {
        loadStats()
        loadRecentActivities()
    }
    
    private func loadStats() {
        stats = [
            StatItem(title: "Proyectos", value: "12", icon: "folder.fill", color: .blue),
            StatItem(title: "Documentos", value: "48", icon: "doc.fill", color: .green),
            StatItem(title: "Favoritos", value: "8", icon: "heart.fill", color: .red),
            StatItem(title: "Herramientas", value: "24", icon: "wrench.fill", color: .orange)
        ]
    }
    
    private func loadRecentActivities() {
        recentActivities = [
            ActivityItem(title: "Documento modificado", subtitle: "Proyecto 1.md", time: "1h"),
            ActivityItem(title: "Documento modificado", subtitle: "Proyecto 2.md", time: "2h"),
            ActivityItem(title: "Documento modificado", subtitle: "Proyecto 3.md", time: "3h"),
            ActivityItem(title: "Documento modificado", subtitle: "Proyecto 4.md", time: "4h"),
            ActivityItem(title: "Documento modificado", subtitle: "Proyecto 5.md", time: "5h")
        ]
    }
}