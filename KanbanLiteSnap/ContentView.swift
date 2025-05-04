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
    
    var focusTasks: [Task] {
        tasks.filter { $0.status == .focus }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(focusTasks) { task in
                        TaskRow(task: task, moveToDone: {
                            task.status = .achievements
                            try? modelContext.save()
                        })
                    }
                }
            }
            .navigationTitle(TaskStatus.focus.displayName)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingTodoList = true }) {
                        Label("TODO", systemImage: "list.bullet")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingTaskTypes = true }) {
                        Label("Types", systemImage: "tag")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDoneList = true }) {
                        Label("Done", systemImage: "checkmark.circle")
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

#Preview {
    ContentView()
} 
