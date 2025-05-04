import SwiftUI
import SwiftData

struct TodoListView: View {
    @Query(sort: [SortDescriptor(\Task.createdAt)]) var tasks: [Task]
    @Query(sort: [SortDescriptor(\TaskType.name)]) var taskTypes: [TaskType]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    @State private var expandedTypes: Set<UUID> = []
    private let noTypeUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    var groupedTasks: [(type: TaskType?, tasks: [Task])] {
        let ideas = tasks.filter { $0.status == .ideas }
        let grouped = Dictionary(grouping: ideas, by: { $0.taskType })
        return grouped
            .sorted { (lhs, rhs) in (lhs.key?.name ?? "") < (rhs.key?.name ?? "") }
            .map { (key, value) in (type: key, tasks: value) }
    }
    
    var allGroupIds: [UUID] {
        groupedTasks.map { $0.type?.id ?? noTypeUUID }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedTasks.indices, id: \.self) { idx in
                    let group = groupedTasks[idx]
                    let groupId = group.type?.id ?? noTypeUUID
                    TaskTypeSectionView(
                        group: group,
                        isExpanded: expandedTypes.contains(groupId),
                        toggle: {
                            if expandedTypes.contains(groupId) {
                                expandedTypes.remove(groupId)
                            } else {
                                expandedTypes.insert(groupId)
                            }
                        },
                        moveToFocus: { task in
                            withAnimation {
                                task.status = .focus
                                try? modelContext.save()
                            }
                        }
                    )
                }
            }
            .navigationTitle(TaskStatus.ideas.displayName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet(taskTypes: taskTypes) { title, description, type in
                    let newTask = Task(title: title, details: description, taskType: type, status: .ideas)
                    modelContext.insert(newTask)
                    try? modelContext.save()
                }
            }
            .onAppear {
                expandedTypes = Set(allGroupIds)
            }
            .onChange(of: tasks.count) {
                expandedTypes = Set(allGroupIds)
            }
        }
    }
}

struct TaskTypeSectionView: View {
    let group: (type: TaskType?, tasks: [Task])
    let isExpanded: Bool
    let toggle: () -> Void
    let moveToFocus: (Task) -> Void
    private let noTypeUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    var body: some View {
        Section(header: HStack {
            Text(group.type?.name ?? "Sin tipo")
                .font(.headline)
            Spacer()
            Button(action: toggle) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }) {
            if isExpanded {
                ForEach(group.tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        if let details = task.details {
                            Text(details)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Button(action: { moveToFocus(task) }) {
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.blue)
                                .help("Mover a Focus")
                        }
                    }
                }
            }
        }
    }
}

struct AddTaskSheet: View {
    var taskTypes: [TaskType]
    var onAdd: (String, String?, TaskType?) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedTaskType: TaskType?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $taskTitle)
                    TextField("Description (optional)", text: $taskDescription)
                }
                Section(header: Text("Task Type")) {
                    Picker("Type", selection: $selectedTaskType) {
                        Text("None").tag(nil as TaskType?)
                        ForEach(taskTypes) { type in
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
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    if !taskTitle.isEmpty {
                        onAdd(taskTitle, taskDescription.isEmpty ? nil : taskDescription, selectedTaskType)
                        dismiss()
                    }
                }
            )
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
} 
