//
//  fitnessApp.swift
//  fitness
//
//  Created by 鬼頭拓万 on 2023/11/23.
//

import SwiftUI

@main
struct fitnessApp: App {
    let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
