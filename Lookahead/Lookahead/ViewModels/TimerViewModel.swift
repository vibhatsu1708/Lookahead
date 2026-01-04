//
//  TimerViewModel.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation
import SwiftUI
import Combine

enum TimerState {
    case idle
    case ready      // Holding down, preparing to start
    case running    // Timer is active
    case stopped    // Just stopped, showing time
}

@MainActor
class TimerViewModel: ObservableObject {
    @Published var currentScramble: String = ""
    @Published var selectedCubeType: CubeType = .threeByThree
    @Published var timerState: TimerState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var lastSolveTime: TimeInterval? = nil
    
    private var timer: Timer?
    private var startTime: Date?
    
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
    
    // MARK: - Timer Controls
    
    func prepareTimer() {
        timerState = .ready
        elapsedTime = 0
    }
    
    func startTimer() {
        timerState = .running
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let startTime = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        }
        
        lastSolveTime = elapsedTime
        timerState = .stopped
        startTime = nil
    }
    
    func resetToIdle() {
        timerState = .idle
        generateNewScramble()
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
        formatTime(elapsedTime)
    }
}

