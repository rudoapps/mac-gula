import Foundation
import SwiftUI

struct StatItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let time: String
}

struct GulaStatus {
    let projectCreated: Date?
    let gulaVersion: String
    let installedModules: [GulaModule]
    let hasProject: Bool
    let statistics: GulaStatistics?
    let generatedTemplates: [GulaTemplate]
}

struct GulaStatistics {
    let successfulInstalls: Int
    let generatedTemplates: Int
    let listingsPerformed: Int
    let operationsWithError: Int
    let totalOperations: Int
}

struct GulaModule: Identifiable {
    let id = UUID()
    let name: String
    let platform: String
    let branch: String
    let installDate: Date?
}

struct GulaTemplate: Identifiable {
    let id = UUID()
    let name: String
    let platform: String
    let generatedDate: Date?
}