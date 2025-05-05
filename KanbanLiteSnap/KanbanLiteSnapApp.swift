//
//  Kanban_LiteSnapApp.swift
//  Kanban LiteSnap
//
//  Created by Antonio J. González on 4/5/25.
//

import SwiftUI
import SwiftData

@main
struct KanbanLiteSnapApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: Task.self, TaskType.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(modelContainer)
    }
}
