import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var taskTypes: [TaskType] = [
        TaskType(name: "Work", icon: "briefcase.fill", color: .blue),
        TaskType(name: "Personal", icon: "person.fill", color: .green),
        TaskType(name: "Shopping", icon: "cart.fill", color: .orange),
        TaskType(name: "Health", icon: "heart.fill", color: .red),
        TaskType(name: "Study", icon: "book.fill", color: .purple)
    ]
    
    func addTask(title: String, details: String? = nil, taskType: TaskType? = nil, status: TaskStatus = .ideas) {
        let task = Task(title: title, details: details, taskType: taskType, status: status)
        tasks.append(task)
    }
    
    func moveTask(_ task: Task, to status: TaskStatus) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].status = status
        }
    }
    
    func getTasks(for status: TaskStatus) -> [Task] {
        tasks.filter { $0.status == status }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    func restoreTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].status = .focus
        }
    }
    
    func addTaskType(name: String, icon: String, color: Color) {
        let taskType = TaskType(name: name, icon: icon, color: color)
        taskTypes.append(taskType)
    }
    
    func deleteTaskType(_ taskType: TaskType) {
        taskTypes.removeAll { $0.id == taskType.id }
    }
} 
