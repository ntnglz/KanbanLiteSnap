import SwiftUI
import SwiftData

struct DoneListView: View {
    @Query(sort: [SortDescriptor(\Task.createdAt)]) var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    
    var doneTasks: [Task] {
        tasks.filter { $0.status == .achievements }
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
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
                                task.status = .focus
                                try? modelContext.save()
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.blue)
                            }
                            Button(action: {
                                modelContext.delete(task)
                                try? modelContext.save()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle(TaskStatus.achievements.displayName)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
            )
        }
    }
} 
