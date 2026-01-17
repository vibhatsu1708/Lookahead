//
//  TimerViewModel.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation
import SwiftUI
import CoreData

enum TimerState {
    case idle
    case ready      // Holding down, preparing to start
    case inspection // Inspection time running
    case running    // Timer is active
    case stopped    // Just stopped, showing time
}

enum TimerPhase {
    case inspection
    case solving
}

@MainActor
class TimerViewModel: ObservableObject {
    @Published var currentScramble: String = ""
    @Published var selectedCubeType: CubeType = .threeByThree
    @Published var timerState: TimerState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var inspectionTimeRemaining: TimeInterval = 15
    @Published var inspectionEnabled: Bool = false {
        didSet {
            if timerState == .idle {
                nextPhase = inspectionEnabled ? .inspection : .solving
            }
        }
    }
    @Published var lastSolveTime: TimeInterval? = nil
    @Published var lastSolvePenalty: SolvePenalty = .none
    
    // Phase management
    private(set) var nextPhase: TimerPhase = .solving
    
    private var timer: Timer?
    private var startTime: Date?
    private var lastScramble: String = ""
    private(set) var lastSavedSolve: SolveEntity?
    
    init() {
        generateNewScramble()
    }
    
    // MARK: - Scramble Management
    
    func generateNewScramble() {
        currentScramble = ScrambleGenerator.generate(for: selectedCubeType)
    }
    
    func changeCubeType(to type: CubeType) {
        selectedCubeType = type
        generateNewScramble()
    }
    
    /// Sync cube type with current session
    func syncWithSession(_ session: SessionEntity?) {
        if let session = session {
            selectedCubeType = session.cubeTypeEnum
            generateNewScramble()
        }
    }
    
    // MARK: - Timer Controls
    
    func prepareTimer() {
        // If we are inspecting, next up is solving.
        // If we are idle, next up depends on settings (which sets nextPhase).
        timerState = .ready
        
        if timerState != .inspection && nextPhase == .solving {
            elapsedTime = 0
            lastSolvePenalty = .none
        }
    }
    
    func triggerPhaseChange() {
        if nextPhase == .inspection {
            startInspection()
            // After inspection starts, the next phase is solving
            nextPhase = .solving
        } else {
            startTimer()
        }
    }
    
    func startInspection() {
        timerState = .inspection
        inspectionTimeRemaining = 15
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.inspectionTimeRemaining -= 0.1
                
                if self.inspectionTimeRemaining <= -2 {
                    // DNF if inspection goes too long (standard +2 is usually at 15-17s, DNF after)
                    // For simplicity, let's auto-DNF or just keep negative counter?
                    // User request doesn't specify penalty logic for inspection overstay.
                    // Keeping simple: just count down. 
                }
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate() // Stop inspection timer if running
        timerState = .running
        startTime = Date()
        lastScramble = currentScramble
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let startTime = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stopTimer(context: NSManagedObjectContext, session: SessionEntity?) {
        timer?.invalidate()
        timer = nil
        
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        }
        
        lastSolveTime = elapsedTime
        lastSolvePenalty = .none
        timerState = .stopped
        startTime = nil
        
        // Save the solve to Core Data
        saveSolve(context: context, session: session)
    }
    
    func resetToIdle() {
        timerState = .idle
        elapsedTime = 0
        lastSavedSolve = nil
        lastSolvePenalty = .none
        generateNewScramble()
        
        // Determine the first phase of the next solve
        nextPhase = inspectionEnabled ? .inspection : .solving
    }
    
    // MARK: - Penalty Management
    
    func setPenalty(_ penalty: SolvePenalty, context: NSManagedObjectContext) {
        lastSolvePenalty = penalty
        
        // Update the saved solve
        if let solve = lastSavedSolve {
            solve.penaltyType = penalty
            do {
                try context.save()
            } catch {
                print("Error updating penalty: \(error)")
            }
        }
    }
    
    func togglePenalty(_ penalty: SolvePenalty, context: NSManagedObjectContext) {
        if lastSolvePenalty == penalty {
            setPenalty(.none, context: context)
        } else {
            setPenalty(penalty, context: context)
        }
    }
    
    /// Display time with penalty applied
    var displayTimeWithPenalty: String {
        switch lastSolvePenalty {
        case .none:
            return formatTime(elapsedTime)
        case .plusTwo:
            return formatTime(elapsedTime + 2.0) + "+"
        case .dnf:
            return "DNF"
        }
    }
    
    // MARK: - Core Data
    
    private func saveSolve(context: NSManagedObjectContext, session: SessionEntity?) {
        let solve = SolveEntity(context: context)
        solve.id = UUID()
        solve.time = elapsedTime
        solve.scramble = lastScramble
        solve.cubeType = selectedCubeType.rawValue
        solve.date = Date()
        solve.penalty = SolvePenalty.none.rawValue
        solve.isFlagged = false
        solve.comment = nil
        solve.session = session
        
        lastSavedSolve = solve
        
        do {
            try context.save()
        } catch {
            print("Error saving solve: \(error)")
        }
    }
    
    /// Delete the last saved solve and reset to idle
    func deleteLastSolve(context: NSManagedObjectContext) -> Bool {
        guard let solve = lastSavedSolve else { return false }
        
        context.delete(solve)
        
        do {
            try context.save()
            lastSavedSolve = nil
            resetToIdle()
            return true
        } catch {
            print("Error deleting solve: \(error)")
            return false
        }
    }
    
    /// Check if there's a solve that can be deleted
    var canDeleteLastSolve: Bool {
        lastSavedSolve != nil && timerState == .stopped
    }
    
    // MARK: - Flag Management
    
    var isLastSolveFlagged: Bool {
        lastSavedSolve?.isFlagged ?? false
    }
    
    func toggleFlag(context: NSManagedObjectContext) {
        guard let solve = lastSavedSolve else { return }
        
        solve.isFlagged.toggle()
        objectWillChange.send()
        
        do {
            try context.save()
        } catch {
            print("Error toggling flag: \(error)")
        }
    }
    
    // MARK: - Comment Management
    
    var lastSolveHasComment: Bool {
        guard let comment = lastSavedSolve?.comment else { return false }
        return !comment.isEmpty
    }
    
    // MARK: - Time Formatting
    
    func formatTime(_ time: TimeInterval) -> String {
        if time < 60 {
            return String(format: "%.2f", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = time.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%05.2f", minutes, seconds)
        }
    }
    
    var displayTime: String {
        if timerState == .stopped {
            return displayTimeWithPenalty
        } else if timerState == .inspection {
            return String(format: "%d", Int(ceil(inspectionTimeRemaining)))
        }
        return formatTime(elapsedTime)
    }
}
