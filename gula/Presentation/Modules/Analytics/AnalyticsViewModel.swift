import Foundation
import SwiftUI

class AnalyticsViewModel: ObservableObject {
    @Published var metrics: [MetricCard] = []
    @Published var recentItems: [RecentMetric] = []
    @Published var weekData: [Int] = []
    @Published var weekDays: [String] = []
    
    func loadData() {
        loadMetrics()
        loadRecentActivity()
        loadWeeklyData()
    }
    
    private func loadMetrics() {
        metrics = [
            MetricCard(
                title: "Documentos Creados",
                value: "156",
                change: "+12%",
                changeType: .positive,
                icon: "doc.text.fill",
                color: .blue
            ),
            MetricCard(
                title: "Tiempo Activo",
                value: "48h",
                change: "+5%",
                changeType: .positive,
                icon: "clock.fill",
                color: .green
            ),
            MetricCard(
                title: "Proyectos",
                value: "24",
                change: "0%",
                changeType: .neutral,
                icon: "folder.fill",
                color: .orange
            ),
            MetricCard(
                title: "Colaboradores",
                value: "8",
                change: "+2",
                changeType: .positive,
                icon: "person.2.fill",
                color: .purple
            )
        ]
    }
    
    private func loadRecentActivity() {
        recentItems = [
            RecentMetric(action: "Documento creado", item: "Informe Q3.docx", time: "Hace 2h"),
            RecentMetric(action: "Proyecto actualizado", item: "App Mobile", time: "Hace 4h"),
            RecentMetric(action: "Archivo compartido", item: "Presentación.pdf", time: "Hace 6h"),
            RecentMetric(action: "Comentario añadido", item: "Notas reunión", time: "Hace 8h"),
            RecentMetric(action: "Tarea completada", item: "Revisión código", time: "Hace 1d")
        ]
    }
    
    private func loadWeeklyData() {
        weekData = [3, 7, 5, 8, 6, 9, 4]
        weekDays = ["L", "M", "X", "J", "V", "S", "D"]
    }
}