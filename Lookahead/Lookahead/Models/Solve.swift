//
//  Solve.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation

/// Represents a single solve attempt
struct Solve: Identifiable, Codable {
    let id: UUID
    let time: TimeInterval
    let scramble: String
    let cubeType: String
    let date: Date
    var penalty: SolvePenalty
    var notes: String?
    
    init(
        id: UUID = UUID(),
        time: TimeInterval,
        scramble: String,
        cubeType: CubeType,
        date: Date = Date(),
        penalty: SolvePenalty = .none,
        notes: String? = nil
    ) {
        self.id = id
        self.time = time
        self.scramble = scramble
        self.cubeType = cubeType.rawValue
        self.date = date
        self.penalty = penalty
        self.notes = notes
    }
    
    /// The effective time including any penalty
    var effectiveTime: TimeInterval? {
        switch penalty {
        case .none:
            return time
        case .plusTwo:
            return time + 2.0
        case .dnf:
            return nil // DNF has no time
        }
    }
    
    /// Formatted time string
    var formattedTime: String {
        switch penalty {
        case .dnf:
            return "DNF"
        case .plusTwo:
            return formatTime(time + 2.0) + "+"
        case .none:
            return formatTime(time)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        if time < 60 {
            return String(format: "%.2f", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = time.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%05.2f", minutes, seconds)
        }
    }
}

enum SolvePenalty: String, Codable, CaseIterable {
    case none = "OK"
    case plusTwo = "+2"
    case dnf = "DNF"
}

