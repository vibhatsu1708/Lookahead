//
//  Solve.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation

enum SolvePenalty: String, Codable, CaseIterable {
    case none = "OK"
    case plusTwo = "+2"
    case dnf = "DNF"
    
    var displayName: String {
        switch self {
        case .none: return "OK"
        case .plusTwo: return "+2"
        case .dnf: return "DNF"
        }
    }
}

// MARK: - SolveEntity Extensions

extension SolveEntity {
    var penaltyType: SolvePenalty {
        get {
            SolvePenalty(rawValue: penalty ?? "OK") ?? .none
        }
        set {
            penalty = newValue.rawValue
        }
    }
    
    /// The effective time including any penalty
    var effectiveTime: TimeInterval? {
        switch penaltyType {
        case .none:
            return time
        case .plusTwo:
            return time + 2.0
        case .dnf:
            return nil
        }
    }
    
    /// Formatted time string
    var formattedTime: String {
        switch penaltyType {
        case .dnf:
            return "DNF"
        case .plusTwo:
            return formatTimeValue(time + 2.0) + "+"
        case .none:
            return formatTimeValue(time)
        }
    }
    
    private func formatTimeValue(_ time: TimeInterval) -> String {
        if time < 60 {
            return String(format: "%.2f", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = time.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%05.2f", minutes, seconds)
        }
    }
    
    /// Validates and sets comment (max 100 characters)
    func setComment(_ text: String?) {
        if let text = text {
            comment = String(text.prefix(100))
        } else {
            comment = nil
        }
    }
}
