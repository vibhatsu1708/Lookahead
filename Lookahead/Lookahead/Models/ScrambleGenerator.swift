//
//  ScrambleGenerator.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation

struct ScrambleGenerator {
    
    // Standard moves for 3x3 and smaller
    private static let standardMoves = ["R", "L", "U", "D", "F", "B"]
    
    // Additional wide moves for bigger cubes (4x4+)
    private static let wideMoves = ["Rw", "Lw", "Uw", "Dw", "Fw", "Bw"]
    
    // Move modifiers
    private static let modifiers = ["", "'", "2"]
    
    // Opposite faces - can't have consecutive moves on same axis
    private static let opposites: [String: String] = [
        "R": "L", "L": "R",
        "U": "D", "D": "U",
        "F": "B", "B": "F",
        "Rw": "Lw", "Lw": "Rw",
        "Uw": "Dw", "Dw": "Uw",
        "Fw": "Bw", "Bw": "Fw"
    ]
    
    // Same axis faces
    private static let sameAxis: [[String]] = [
        ["R", "L", "Rw", "Lw"],
        ["U", "D", "Uw", "Dw"],
        ["F", "B", "Fw", "Bw"]
    ]
    
    static func generate(for cubeType: CubeType) -> String {
        let length = cubeType.scrambleLength
        var moves: [String] = []
        var lastMove: String? = nil
        var secondLastMove: String? = nil
        
        let availableMoves = getAvailableMoves(for: cubeType)
        
        for _ in 0..<length {
            var validMoves = availableMoves.filter { move in
                // Can't repeat the same base move
                if let last = lastMove, getBaseMove(move) == getBaseMove(last) {
                    return false
                }
                
                // Can't have three moves on the same axis (e.g., R L R)
                if let last = lastMove, let secondLast = secondLastMove {
                    if areOnSameAxis(move, last) && areOnSameAxis(last, secondLast) {
                        return false
                    }
                }
                
                return true
            }
            
            if validMoves.isEmpty {
                validMoves = availableMoves
            }
            
            let randomMove = validMoves.randomElement()!
            let modifier = modifiers.randomElement()!
            
            moves.append(randomMove + modifier)
            
            secondLastMove = lastMove
            lastMove = randomMove
        }
        
        return moves.joined(separator: " ")
    }
    
    private static func getAvailableMoves(for cubeType: CubeType) -> [String] {
        switch cubeType {
        case .twoByTwo:
            // 2x2 only uses R, U, F faces
            return ["R", "U", "F"]
        case .threeByThree:
            return standardMoves
        case .fourByFour, .fiveByFive, .sixBySix, .sevenBySeven:
            // Big cubes use both standard and wide moves
            return standardMoves + wideMoves
        }
    }
    
    private static func getBaseMove(_ move: String) -> String {
        move.replacingOccurrences(of: "'", with: "")
             .replacingOccurrences(of: "2", with: "")
    }
    
    private static func areOnSameAxis(_ move1: String, _ move2: String) -> Bool {
        let base1 = getBaseMove(move1)
        let base2 = getBaseMove(move2)
        
        for axis in sameAxis {
            if axis.contains(base1) && axis.contains(base2) {
                return true
            }
        }
        return false
    }
}

