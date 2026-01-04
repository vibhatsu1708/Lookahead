//
//  PersistenceController.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Lookahead")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview Helper
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        for i in 0..<10 {
            let solve = SolveEntity(context: viewContext)
            solve.id = UUID()
            solve.time = Double.random(in: 8.0...25.0)
            solve.scramble = "R U R' U' R' F R2 U' R' U' R U R' F'"
            solve.cubeType = "3x3"
            solve.date = Date().addingTimeInterval(-Double(i * 3600))
            solve.penalty = "OK"
        }
        
        try? viewContext.save()
        return controller
    }()
    
    // MARK: - Save Context
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

