//
//  Persistent.swift
//  fitness
//
//  Created by 鬼頭拓万 on 2023/12/14.
//

import CoreData

// containerの作成
struct PersistenceController {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "FoodMF")
        
        container.loadPersistentStores(completionHandler: { (NSPersistentStoreDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        })
    }
}
