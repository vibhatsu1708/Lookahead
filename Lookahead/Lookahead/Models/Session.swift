//
//  Session.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation
import CoreData

// MARK: - SessionEntity Extensions

extension SessionEntity {
    var cubeTypeEnum: CubeType {
        get {
            CubeType(rawValue: cubeType ?? "3x3") ?? .threeByThree
        }
        set {
            cubeType = newValue.rawValue
        }
    }
    
    var solvesArray: [SolveEntity] {
        let set = solves as? Set<SolveEntity> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    var solveCount: Int {
        solves?.count ?? 0
    }
    
    // MARK: - Statistics
    
    var bestTime: TimeInterval? {
        solvesArray
            .filter { $0.penaltyType != .dnf }
            .compactMap { $0.effectiveTime }
            .min()
    }
    
    var averageTime: TimeInterval? {
        let validSolves = solvesArray.filter { $0.penaltyType != .dnf }
        guard !validSolves.isEmpty else { return nil }
        let total = validSolves.compactMap { $0.effectiveTime }.reduce(0, +)
        return total / Double(validSolves.count)
    }
    
    var ao5: TimeInterval? {
        let recentSolves = Array(solvesArray.prefix(5))
        guard recentSolves.count >= 5 else { return nil }
        
        if recentSolves.contains(where: { $0.penaltyType == .dnf }) {
            return nil
        }
        
        let times = recentSolves.compactMap { $0.effectiveTime }.sorted()
        guard times.count >= 5 else { return nil }
        let middleThree = Array(times.dropFirst().dropLast())
        return middleThree.reduce(0, +) / 3.0
    }
    
    var ao12: TimeInterval? {
        let recentSolves = Array(solvesArray.prefix(12))
        guard recentSolves.count >= 12 else { return nil }
        
        if recentSolves.contains(where: { $0.penaltyType == .dnf }) {
            return nil
        }
        
        let times = recentSolves.compactMap { $0.effectiveTime }.sorted()
        guard times.count >= 12 else { return nil }
        let middleTen = Array(times.dropFirst().dropLast())
        return middleTen.reduce(0, +) / 10.0
    }
}

