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
        
        // Create sample sessions
        let session1 = SessionEntity(context: viewContext)
        session1.id = UUID()
        session1.name = "Practice"
        session1.cubeType = "3x3"
        session1.createdAt = Date()
        
        let session2 = SessionEntity(context: viewContext)
        session2.id = UUID()
        session2.name = "Competition Prep"
        session2.cubeType = "3x3"
        session2.createdAt = Date().addingTimeInterval(-86400)
        
        let session3 = SessionEntity(context: viewContext)
        session3.id = UUID()
        session3.name = "4x4 Practice"
        session3.cubeType = "4x4"
        session3.createdAt = Date().addingTimeInterval(-172800)
        
        // Create sample solves for session1
        let scrambles = [
            "R U R' U' R' F R2 U' R' U' R U R' F'",
            "F R U R' U' F' U2 R U R' U R U2 R'",
            "R U R' U R U2 R' F R U R' U' F'",
            "U R U' R' U' F' U F R U R' U R U2 R'"
        ]
        
        for i in 0..<10 {
            let solve = SolveEntity(context: viewContext)
            solve.id = UUID()
            solve.time = Double.random(in: 8.0...25.0)
            solve.scramble = scrambles[i % scrambles.count]
            solve.cubeType = "3x3"
            solve.date = Date().addingTimeInterval(-Double(i * 3600))
            solve.penalty = ["OK", "OK", "OK", "+2", "DNF"][Int.random(in: 0..<5)]
            solve.isFlagged = i == 2 || i == 5
            solve.comment = i == 1 ? "PB! Great F2L" : (i == 4 ? "Bad cross" : nil)
            solve.session = session1
        }
        
        // Create some solves for session2
        for i in 0..<5 {
            let solve = SolveEntity(context: viewContext)
            solve.id = UUID()
            solve.time = Double.random(in: 10.0...20.0)
            solve.scramble = scrambles[i % scrambles.count]
            solve.cubeType = "3x3"
            solve.date = Date().addingTimeInterval(-Double(i * 7200))
            solve.penalty = "OK"
            solve.isFlagged = false
            solve.comment = nil
            solve.session = session2
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
