import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedTaskType: TaskType?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $taskTitle)
                    TextField("Description (optional)", text: $taskDescription)
                }
                
                Section(header: Text("Task Type")) {
                    Picker("Type", selection: $selectedTaskType) {
                        Text("None").tag(nil as TaskType?)
                        ForEach(viewModel.taskTypes) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.name)
                            }.tag(type as TaskType?)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    if !taskTitle.isEmpty {
                        viewModel.addTask(
                            title: taskTitle,
                            details: taskDescription.isEmpty ? nil : taskDescription,
                            taskType: selectedTaskType,
                            status: .ideas
                        )
                        dismiss()
                    }
                }
            )
        }
    }
} 
