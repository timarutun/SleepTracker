//
//  SleepTrackerApp.swift
//  SleepTracker
//
//  Created by Timur on 6/19/24.
//

import SwiftUI

@main
struct SleepTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
