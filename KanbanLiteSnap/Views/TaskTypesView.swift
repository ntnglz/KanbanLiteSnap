import SwiftUI
import SwiftData

/// Vista para gestionar los tipos de tarea (añadir, eliminar, listar).
struct TaskTypesView: View {
    @Query(sort: [SortDescriptor(\TaskType.name)]) var taskTypes: [TaskType]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var showingAddType = false
    @State private var newTypeName = ""
    @State private var newTypeIcon = "bolt.fill"
    @State private var newTypeColor = Color.blue
    let icons = ["bolt.fill", "list.bullet", "star.fill", "tag.fill", "heart.fill", "cart.fill", "book.fill", "person.fill", "briefcase.fill", "pencil", "calendar", "checkmark.circle.fill"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(taskTypes) { type in
                    HStack {
                        Image(systemName: type.icon)
                            .foregroundColor(type.color)
                            .font(.title2)
                            .frame(width: 30)
                        Text(type.name)
                        Spacer()
                        Button(action: {
                            let tasksWithType = try? modelContext.fetch(FetchDescriptor<Task>())
                            let filteredTasks = tasksWithType?.filter { $0.taskType?.id == type.id } ?? []
                            for task in filteredTasks {
                                task.taskType = nil
                            }
                            modelContext.delete(type)
                            try? modelContext.save()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("taskTypes.title".localized)
            .navigationBarItems(
                leading: Button("common.done".localized) {
                    dismiss()
                },
                trailing: Button(action: { showingAddType = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddType) {
                Form {
                    TextField("taskTypes.name".localized, text: $newTypeName)
                    Section(header: Text("taskTypes.icon".localized)) {
                        Picker("taskTypes.icon".localized, selection: $newTypeIcon) {
                            ForEach(icons, id: \.self) { icon in
                                HStack {
                                    Image(systemName: icon)
                                    Text(icon)
                                }.tag(icon)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    ColorPicker("taskTypes.color".localized, selection: $newTypeColor)
                    Button("common.add".localized) {
                        if !newTypeName.isEmpty {
                            let newType = TaskType(name: newTypeName, icon: newTypeIcon, color: newTypeColor)
                            modelContext.insert(newType)
                            try? modelContext.save()
                            newTypeName = ""
                            newTypeIcon = "bolt.fill"
                            newTypeColor = .blue
                            showingAddType = false
                            dismiss()
                        }
                    }
                }
            }
        }
    }
} 
