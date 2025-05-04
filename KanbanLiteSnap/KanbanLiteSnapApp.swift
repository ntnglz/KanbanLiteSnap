//
//  Kanban_LiteSnapApp.swift
//  Kanban LiteSnap
//
//  Created by Antonio J. González on 4/5/25.
//

import SwiftUI
import SwiftData

@main
struct Kanban_LiteSnapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Task.self, TaskType.self])
    }
}
