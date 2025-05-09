import SwiftUI
import SwiftData

/// Vista que muestra las tareas completadas (Achievements) y permite restaurarlas o eliminarlas.
struct DoneListView: View {
    @Query(sort: [SortDescriptor(\Task.createdAt)]) var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    
    var doneTasks: [Task] {
        tasks.filter { $0.status == .achievements }
    }
    
    @Environment(\.dismiss) var dismiss
    @State private var taskToDelete: Task?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 16) {
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 256, height: 256)
                        .opacity(0.25)
                    Text("achievements.welcome".localized)
                        .font(.headline)
                        .opacity(0.25)
                    Text("achievements.instructions".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(0.25)
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
                
                List {
                    ForEach(doneTasks) { task in
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
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        task.status = .focus
                                        try? modelContext.save()
                                    }
                                }) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: {
                                    taskToDelete = task
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
                .background(Color.clear)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("status.achievements".localized)
            .navigationBarItems(
                leading: Button("common.done".localized) {
                    dismiss()
                }
            )
            .alert("common.delete".localized, isPresented: .init(
                get: { taskToDelete != nil },
                set: { if !$0 { taskToDelete = nil } }
            )) {
                Button("common.cancel".localized, role: .cancel) {
                    taskToDelete = nil
                }
                Button("common.delete".localized, role: .destructive) {
                    if let task = taskToDelete {
                        modelContext.delete(task)
                        try? modelContext.save()
                        taskToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this task? This action cannot be undone.")
            }
        }
    }
} 
