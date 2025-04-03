//
//  SwiftDataZeroToHeroApp.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataZeroToHeroApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(.sharedModelContainer)
    }
}

extension ModelContainer {
  static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Friend.self, Post.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
