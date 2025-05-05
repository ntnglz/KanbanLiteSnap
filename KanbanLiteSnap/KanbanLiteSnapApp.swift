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
        // Configure localization
        let locale = Locale.current
        if locale.language.languageCode?.identifier == "es" {
            Bundle.main.setLanguage("es")
        } else {
            Bundle.main.setLanguage("en")
        }
        
        // Initialize SwiftData
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

// Extension to handle language switching
extension Bundle {
    func setLanguage(_ language: String) {
        objc_setAssociatedObject(self, &Bundle.bundleKey, language, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private static var bundleKey: UInt8 = 0
    
    func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let language = objc_getAssociatedObject(self, &Bundle.bundleKey) as? String,
           let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        // Use a system bundle created from the main bundle path to avoid recursion
        let systemBundle = Bundle(path: Bundle.main.bundlePath) ?? Bundle.main
        return systemBundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
