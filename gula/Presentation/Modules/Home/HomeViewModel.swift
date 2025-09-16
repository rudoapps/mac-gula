import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var stats: [StatItem] = []
    @Published var recentActivities: [ActivityItem] = []
    @Published var gulaStatus: GulaStatus?
    @Published var isLoadingStatus = false
    
    private let projectManager = ProjectManager.shared
    
    func loadData() {
        print("🏠 HomeViewModel: loadData() llamado")
        loadStats()
        loadRecentActivities()
        loadGulaStatus()
    }
    
    private func loadStats() {
        updateStatsWithGulaInfo()
    }
    
    private func updateStatsWithGulaInfo() {
        stats = [
            StatItem(title: "Proyectos", value: "\(projectManager.recentProjects.count)", icon: "folder.fill", color: .blue),
            StatItem(title: "Documentos", value: "48", icon: "doc.fill", color: .green),
            StatItem(title: "Favoritos", value: "8", icon: "heart.fill", color: .red),
            StatItem(title: "Herramientas", value: "24", icon: "wrench.fill", color: .orange)
        ]
    }
    
    private func loadGulaStatus() {
        print("🔍 HomeViewModel: loadGulaStatus() llamado")
        print("🔍 HomeViewModel: currentProject = \(projectManager.currentProject?.name ?? "nil")")
        
        guard projectManager.currentProject != nil else {
            print("🔍 HomeViewModel: No hay proyecto actual, estableciendo estado sin proyecto")
            gulaStatus = GulaStatus(
                projectCreated: nil,
                gulaVersion: "Sin proyecto",
                installedModules: [],
                hasProject: false,
                statistics: nil,
                generatedTemplates: []
            )
            isLoadingStatus = false
            updateStatsWithGulaInfo()
            return
        }
        
        // Evitar cargas duplicadas
        guard !isLoadingStatus else { 
            print("🔍 HomeViewModel: Ya está cargando, saliendo")
            return 
        }
        
        print("🔍 HomeViewModel: Iniciando carga de gula status")
        isLoadingStatus = true
        
        Task {
            print("🔍 HomeViewModel: Ejecutando Task para gula status")
            do {
                let status = try await projectManager.getProjectStatus()
                print("🔍 HomeViewModel: gula status obtenido exitosamente")
                
                await MainActor.run {
                    self.gulaStatus = status
                    self.isLoadingStatus = false
                    self.updateStatsWithGulaInfo()
                    self.updateActivitiesWithModules()
                    print("🔍 HomeViewModel: Estado actualizado en MainActor")
                }
            } catch {
                print("🔍 HomeViewModel: Error en gula status: \(error)")
                await MainActor.run {
                    self.gulaStatus = GulaStatus(
                        projectCreated: nil,
                        gulaVersion: "Error",
                        installedModules: [],
                        hasProject: false,
                        statistics: nil,
                        generatedTemplates: []
                    )
                    self.isLoadingStatus = false
                    self.updateStatsWithGulaInfo()
                }
            }
        }
    }
    
    private func loadRecentActivities() {
        updateActivitiesWithModules()
    }
    
    private func updateActivitiesWithModules() {
        // Mostrar actividades generales independientemente del status de gula
        var activities: [ActivityItem] = []
        
        // Agregar proyectos recientes
        for project in projectManager.recentProjects.prefix(3) {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            let timeText = formatter.string(from: project.lastOpened)
            
            activities.append(ActivityItem(
                title: "Proyecto abierto: \(project.name)",
                subtitle: project.type.rawValue.capitalized,
                time: timeText
            ))
        }
        
        // Si hay información de gula status, agregar algunos módulos
        if let status = gulaStatus, status.hasProject {
            let sortedModules = status.installedModules.sorted { module1, module2 in
                guard let date1 = module1.installDate, let date2 = module2.installDate else {
                    return module1.installDate != nil
                }
                return date1 > date2
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            for module in sortedModules.prefix(2) {
                let timeText: String
                if let installDate = module.installDate {
                    timeText = dateFormatter.string(from: installDate)
                } else {
                    timeText = "N/A"
                }
                
                activities.append(ActivityItem(
                    title: "Módulo instalado: \(module.name)",
                    subtitle: "\(module.platform) (\(module.branch))",
                    time: timeText
                ))
            }
        }
        
        // Si no hay actividades, mostrar actividades de ejemplo
        if activities.isEmpty {
            activities = [
                ActivityItem(title: "Bienvenido a Gula", subtitle: "Comienza creando o seleccionando un proyecto", time: "Ahora"),
                ActivityItem(title: "Explora las funciones", subtitle: "Revisa las diferentes secciones disponibles", time: ""),
                ActivityItem(title: "Documentación", subtitle: "Consulta la ayuda para más información", time: "")
            ]
        }
        
        recentActivities = activities
    }
}