import Foundation
import SwiftUI

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