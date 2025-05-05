import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Task.createdAt)]) var tasks: [Task]
    @Query(sort: [SortDescriptor(\TaskType.name)]) var taskTypes: [TaskType]
    @Environment(\.modelContext) private var modelContext
    @State private var showingTodoList = false
    @State private var showingAddTask = false
    @State private var showingDoneList = false
    @State private var showingTaskTypes = false
    @State private var showingAddType = false
    
    let focusMotivationalTitles = [
        "focus.motivational.1".localized,
        "focus.motivational.2".localized,
        "focus.motivational.3".localized,
        "focus.motivational.4".localized,
        "focus.motivational.5".localized
    ]
    @State private var selectedFocusTitle: String = ""
    
    var focusTasks: [Task] {
        tasks.filter { $0.status == .focus }
    }
    
    var body: some View {
        if taskTypes.isEmpty {
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "bolt.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                Text("welcome.title".localized)
                    .font(.title)
                    .bold()
                Text("welcome.message".localized)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button(action: { showingAddType = true }) {
                    Label("welcome.createFirstType".localized, systemImage: "plus")
                        .font(.headline)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                }
                Spacer()
            }
            .sheet(isPresented: $showingAddType) {
                AddTaskTypeSheet()
            }
        } else {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .resizable()
                            .frame(width: 256, height: 256)
                            .opacity(0.25)
                        Text("focus.welcome".localized)
                            .font(.headline)
                            .opacity(0.25)
                        Text("focus.instructions".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(0.25)
                    }
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity)
                    
                    List {
                        ForEach(focusTasks) { task in
                            TaskRow(task: task, moveToDone: {
                                task.status = .achievements
                                try? modelContext.save()
                            })
                        }
                    }
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle(selectedFocusTitle)
                .onAppear {
                    if selectedFocusTitle.isEmpty {
                        selectedFocusTitle = focusMotivationalTitles.randomElement()!
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingTodoList = true }) {
                            Label("status.ideas".localized, systemImage: "list.bullet")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingTaskTypes = true }) {
                            Label("taskTypes.title".localized, systemImage: "tag")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingDoneList = true }) {
                            Label("status.achievements".localized, systemImage: "checkmark.circle")
                        }
                    }
                }
                .sheet(isPresented: $showingTodoList) {
                    TodoListView()
                }
                .sheet(isPresented: $showingAddTask) {
                    AddTaskSheet(taskTypes: taskTypes) { title, details, type in
                        let newTask = Task(title: title, details: details, taskType: type, status: .focus)
                        modelContext.insert(newTask)
                        try? modelContext.save()
                    }
                }
                .sheet(isPresented: $showingDoneList) {
                    DoneListView()
                }
                .sheet(isPresented: $showingTaskTypes) {
                    TaskTypesView()
                }
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    var moveToDone: () -> Void
    
    var body: some View {
        HStack {
            if let taskType = task.taskType {
                Image(systemName: taskType.icon)
                    .foregroundColor(taskType.color)
                    .font(.title2)
                    .frame(width: 30)
            }
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                if let details = task.details {
                    Text(details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(action: moveToDone) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            }
        }
    }
}

// Sheet para crear un nuevo tipo de tarea desde la pantalla de bienvenida
struct AddTaskTypeSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var selectedIcon = "bolt.fill"
    @State private var color = Color.blue
    let icons = ["bolt.fill", "list.bullet", "star.fill", "tag.fill", "heart.fill", "cart.fill", "book.fill", "person.fill", "briefcase.fill", "pencil", "calendar", "checkmark.circle.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nombre")) {
                    TextField("Nombre del tipo", text: $name)
                }
                Section(header: Text("Icono")) {
                    Picker("Icono", selection: $selectedIcon) {
                        ForEach(icons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                Text(icon)
                            }.tag(icon)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                Section(header: Text("Color")) {
                    ColorPicker("Color", selection: $color)
                }
            }
            .navigationTitle("Nuevo tipo de tarea")
            .navigationBarItems(
                leading: Button("Cancelar") { dismiss() },
                trailing: Button("Crear") {
                    if !name.isEmpty {
                        let newType = TaskType(name: name, icon: selectedIcon, color: color)
                        modelContext.insert(newType)
                        try? modelContext.save()
                        dismiss()
                    }
                }
            )
        }
    }
}

#Preview {
    ContentView()
} 
