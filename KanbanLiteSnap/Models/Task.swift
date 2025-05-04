import Foundation
import SwiftUI
import SwiftData

// Modelos de datos persistentes para KanbanLiteSnap

/// Representa el estado de una tarea en el flujo Kanban.
enum TaskStatus: String, CaseIterable {
    case ideas = "IDEAS"        // Antes TODO
    case focus = "FOCUS"        // Antes DOING
    case achievements = "ACHIEVEMENTS"  // Antes DONE
    
    var displayName: String {
        switch self {
        case .ideas: return "Ideas"
        case .focus: return "Focus"
        case .achievements: return "Achievements"
        }
    }
    
    var description: String {
        switch self {
        case .ideas: return "Your creative space for new ideas"
        case .focus: return "Tasks you're actively working on"
        case .achievements: return "Your completed accomplishments"
        }
    }
}

/// Representa un tipo de tarea (categoría) personalizable por el usuario.
@Model
final class TaskType {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = color.toHex()
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    var displayName: String { name }
}

/// Representa una tarea individual en el sistema Kanban.
@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String?
    var statusRaw: String
    var createdAt: Date
    var taskType: TaskType?
    
    init(id: UUID = UUID(), title: String, details: String? = nil, taskType: TaskType? = nil, status: TaskStatus = .ideas) {
        self.id = id
        self.title = title
        self.details = details
        self.taskType = taskType
        self.statusRaw = status.rawValue
        self.createdAt = Date()
    }
    
    var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .ideas }
        set { statusRaw = newValue.rawValue }
    }
}

// Extensiones para Color <-> Hex
extension Color {
    func toHex() -> String {
        UIColor(self).toHex() ?? "#000000"
    }
    
    init(hex: String) {
        self = Color(UIColor(hex: hex))
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    func toHex() -> String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
} 
