import SwiftUI
import SwiftData

struct TaskTypesView: View {
    @Query(sort: [SortDescriptor(\TaskType.name)]) var taskTypes: [TaskType]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var showingAddType = false
    @State private var newTypeName = ""
    @State private var newTypeIcon = "circle.fill"
    @State private var newTypeColor = Color.blue
    
    var body: some View {
        NavigationView {
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
                            modelContext.delete(type)
                            try? modelContext.save()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Task Types")
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                },
                trailing: Button(action: { showingAddType = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddType) {
                Form {
                    TextField("Type Name", text: $newTypeName)
                    TextField("Icon Name", text: $newTypeIcon)
                    ColorPicker("Color", selection: $newTypeColor)
                    Button("Add") {
                        let newType = TaskType(name: newTypeName, icon: newTypeIcon, color: newTypeColor)
                        modelContext.insert(newType)
                        try? modelContext.save()
                        showingAddType = false
                        newTypeName = ""
                        newTypeIcon = "circle.fill"
                        newTypeColor = .blue
                    }
                }
            }
        }
    }
} 