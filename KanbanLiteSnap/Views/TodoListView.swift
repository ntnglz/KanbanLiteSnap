import SwiftUI
import SwiftData

/// Vista que muestra todas las ideas pendientes agrupadas por tipo, permite añadir nuevas tareas y moverlas a Focus.
struct TodoListView: View {
    @Query(sort: [SortDescriptor(\Task.createdAt)]) var tasks: [Task]
    @Query(sort: [SortDescriptor(\TaskType.name)]) var taskTypes: [TaskType]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTask = false
    @State private var expandedTypes: Set<UUID> = []
    @Environment(\.dismiss) var dismiss
    private let noTypeUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    let motivationalTitles = [
        "ideas.motivational.1".localized,
        "ideas.motivational.2".localized,
        "ideas.motivational.3".localized,
        "ideas.motivational.4".localized,
        "ideas.motivational.5".localized
    ]
    @State private var selectedTitle: String = ""
    
    var groupedTasks: [(groupId: UUID, type: TaskType?, tasks: [Task])] {
        let ideas = tasks.filter { $0.status == .ideas }
        let grouped = Dictionary(grouping: ideas, by: { $0.taskType })
        return grouped
            .sorted { (lhs, rhs) in (lhs.key?.name ?? "") < (rhs.key?.name ?? "") }
            .map { (key, value) in (groupId: key?.id ?? noTypeUUID, type: key, tasks: value) }
    }
    
    var allGroupIds: [UUID] {
        groupedTasks.map { $0.groupId }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 16) {
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 256, height: 256)
                        .opacity(0.25)
                    Text("ideas.welcome".localized)
                        .font(.headline)
                        .opacity(0.25)
                    Text("ideas.instructions".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(0.25)
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
                
                List {
                    ForEach(groupedTasks, id: \.groupId) { group in
                        let groupId = group.groupId
                        TaskTypeSectionView(
                            group: (type: group.type, tasks: group.tasks),
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
                .background(Color.clear)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(selectedTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationBarItems(
                leading: Button("common.done".localized) {
                    dismiss()
                }
            )
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet(taskTypes: taskTypes) { title, description, type in
                    let newTask = Task(title: title, details: description, taskType: type, status: .ideas)
                    modelContext.insert(newTask)
                    try? modelContext.save()
                }
            }
            .onAppear {
                expandedTypes = Set(allGroupIds)
                if selectedTitle.isEmpty {
                    selectedTitle = motivationalTitles.randomElement()!
                }
            }
            .onChange(of: tasks.count) {
                expandedTypes = Set(allGroupIds)
            }
        }
    }
}

/// Sección expandible/colapsable para mostrar tareas de un tipo concreto.
struct TaskTypeSectionView: View {
    let group: (type: TaskType?, tasks: [Task])
    let isExpanded: Bool
    let toggle: () -> Void
    let moveToFocus: (Task) -> Void
    private let noTypeUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    var body: some View {
        Section(header: HStack {
            Text(group.type?.name ?? "common.none".localized)
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

/// Sheet para añadir una nueva tarea desde la vista de Ideas.
struct AddTaskSheet: View {
    var taskTypes: [TaskType]
    var onAdd: (String, String?, TaskType?) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedTaskType: TaskType?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("common.title".localized)) {
                    TextField("common.title".localized, text: $taskTitle)
                    TextField("common.description".localized, text: $taskDescription)
                }
                Section(header: Text("common.type".localized)) {
                    Picker("common.type".localized, selection: $selectedTaskType) {
                        Text("common.none".localized).tag(nil as TaskType?)
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
            .navigationTitle("common.add".localized)
            .navigationBarItems(
                leading: Button("common.cancel".localized) { dismiss() },
                trailing: Button("common.add".localized) {
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
