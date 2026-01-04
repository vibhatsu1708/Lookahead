//
//  SessionManager.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class SessionManager: ObservableObject {
    @Published var currentSession: SessionEntity?
    @Published var sessions: [SessionEntity] = []
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadSessions()
        loadCurrentSession()
    }
    
    // MARK: - Load Sessions
    
    func loadSessions() {
        let request: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.createdAt, ascending: false)]
        
        do {
            sessions = try viewContext.fetch(request)
        } catch {
            print("Error fetching sessions: \(error)")
            sessions = []
        }
    }
    
    private func loadCurrentSession() {
        // Try to load the last used session from UserDefaults
        if let sessionIdString = UserDefaults.standard.string(forKey: "currentSessionId"),
           let sessionId = UUID(uuidString: sessionIdString) {
            currentSession = sessions.first { $0.id == sessionId }
        }
        
        // If no session exists, create a default one
        if currentSession == nil {
            if sessions.isEmpty {
                createSession(name: "Default", cubeType: .threeByThree)
            } else {
                currentSession = sessions.first
                saveCurrentSessionId()
            }
        }
    }
    
    // MARK: - Session Management
    
    func createSession(name: String, cubeType: CubeType) {
        let session = SessionEntity(context: viewContext)
        session.id = UUID()
        session.name = name
        session.cubeTypeEnum = cubeType
        session.createdAt = Date()
        
        do {
            try viewContext.save()
            loadSessions()
            switchToSession(session)
        } catch {
            print("Error creating session: \(error)")
        }
    }
    
    func switchToSession(_ session: SessionEntity) {
        currentSession = session
        saveCurrentSessionId()
        objectWillChange.send()
    }
    
    func deleteSession(_ session: SessionEntity) {
        // Don't delete if it's the only session
        guard sessions.count > 1 else { return }
        
        let wasCurrentSession = session.id == currentSession?.id
        
        viewContext.delete(session)
        
        do {
            try viewContext.save()
            loadSessions()
            
            // If we deleted the current session, switch to another one
            if wasCurrentSession {
                currentSession = sessions.first
                saveCurrentSessionId()
            }
        } catch {
            print("Error deleting session: \(error)")
        }
    }
    
    func renameSession(_ session: SessionEntity, to newName: String) {
        session.name = newName
        
        do {
            try viewContext.save()
            loadSessions()
        } catch {
            print("Error renaming session: \(error)")
        }
    }
    
    func updateSessionCubeType(_ session: SessionEntity, to cubeType: CubeType) {
        session.cubeTypeEnum = cubeType
        
        do {
            try viewContext.save()
            loadSessions()
        } catch {
            print("Error updating session cube type: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func saveCurrentSessionId() {
        if let sessionId = currentSession?.id {
            UserDefaults.standard.set(sessionId.uuidString, forKey: "currentSessionId")
        }
    }
    
    func refreshSessions() {
        loadSessions()
        // Refresh current session reference
        if let currentId = currentSession?.id {
            currentSession = sessions.first { $0.id == currentId }
        }
    }
}

