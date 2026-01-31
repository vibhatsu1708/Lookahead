
//
//  CubeState.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

enum CubeFace: CaseIterable {
    case up, down, front, back, left, right
    
    var color: Color {
        switch self {
        case .up: return .white
        case .down: return .yellow
        case .front: return .green
        case .back: return .blue
        case .left: return .orange
        case .right: return .red
        }
    }
}

struct CubeState {
    // 6 faces, each is an NxN grid of colors
    var faces: [CubeFace: [[Color]]]
    let size: Int
    
    init(size: Int = 3) {
        self.size = size
        var initialFaces: [CubeFace: [[Color]]] = [:]
        for face in CubeFace.allCases {
            initialFaces[face] = Array(repeating: Array(repeating: face.color, count: size), count: size)
        }
        self.faces = initialFaces
    }
    
    mutating func apply(moves: String) {
        let moveList = moves.components(separatedBy: " ")
        for move in moveList {
            apply(move: move)
        }
    }
    
    mutating func apply(move: String) {
        let base = move.prefix(1)
        let isPrime = move.contains("'")
        let isDouble = move.contains("2")
        
        let count = isDouble ? 2 : (isPrime ? 3 : 1)
        
        for _ in 0..<count {
            rotateFace(String(base))
        }
    }
    
    private mutating func rotateFace(_ move: String) {
        // This is a simplified 3x3 handler. For NxN handling it gets more complex.
        // We will assume 3x3 logic for now as it's the primary use case.
        
        // Helper to rotate a face clockwise
        func rotateFaceGrid(_ face: CubeFace) {
            guard let grid = faces[face] else { return }
            let n = grid.count
            var newGrid = grid
            for i in 0..<n {
                for j in 0..<n {
                    newGrid[j][n - 1 - i] = grid[i][j]
                }
            }
            faces[face] = newGrid
        }
        
        switch move {
        case "R":
            rotateFaceGrid(.right)
            let temp = getCol(face: .front, col: size-1)
            setCol(face: .front, col: size-1, values: getCol(face: .down, col: size-1))
            setCol(face: .down, col: size-1, values: getCol(face: .back, col: 0).reversed()) // Back is inverted orientation here
            setCol(face: .back, col: 0, values: getCol(face: .up, col: size-1).reversed())
            setCol(face: .up, col: size-1, values: temp)
            
        case "L":
            rotateFaceGrid(.left)
            let temp = getCol(face: .front, col: 0)
            setCol(face: .front, col: 0, values: getCol(face: .up, col: 0))
            setCol(face: .up, col: 0, values: getCol(face: .back, col: size-1).reversed())
            setCol(face: .back, col: size-1, values: getCol(face: .down, col: 0).reversed())
            setCol(face: .down, col: 0, values: temp)
            
        case "U":
            rotateFaceGrid(.up)
            let temp = getRow(face: .front, row: 0)
            setRow(face: .front, row: 0, values: getRow(face: .right, row: 0))
            setRow(face: .right, row: 0, values: getRow(face: .back, row: 0))
            setRow(face: .back, row: 0, values: getRow(face: .left, row: 0))
            setRow(face: .left, row: 0, values: temp)
            
        case "D":
            rotateFaceGrid(.down)
            let temp = getRow(face: .front, row: size-1)
            setRow(face: .front, row: size-1, values: getRow(face: .left, row: size-1))
            setRow(face: .left, row: size-1, values: getRow(face: .back, row: size-1))
            setRow(face: .back, row: size-1, values: getRow(face: .right, row: size-1))
            setRow(face: .right, row: size-1, values: temp)
            
        case "F":
            rotateFaceGrid(.front)
            let temp = getRow(face: .up, row: size-1)
            setRow(face: .up, row: size-1, values: getCol(face: .left, col: size-1).reversed())
            setCol(face: .left, col: size-1, values: getRow(face: .down, row: 0))
            setRow(face: .down, row: 0, values: getCol(face: .right, col: 0).reversed())
            setCol(face: .right, col: 0, values: temp)
            
        case "B":
            rotateFaceGrid(.back)
            let temp = getRow(face: .up, row: 0)
            setRow(face: .up, row: 0, values: getCol(face: .right, col: size-1))
            setCol(face: .right, col: size-1, values: getRow(face: .down, row: size-1).reversed())
            setRow(face: .down, row: size-1, values: getCol(face: .left, col: 0))
            setCol(face: .left, col: 0, values: temp.reversed())
            
        default: break
        }
    }
    
    // Helpers
    private func getRow(face: CubeFace, row: Int) -> [Color] {
        return faces[face]![row]
    }
    
    private mutating func setRow(face: CubeFace, row: Int, values: [Color]) {
        faces[face]![row] = values
    }
    
    private func getCol(face: CubeFace, col: Int) -> [Color] {
        return faces[face]!.map { $0[col] }
    }
    
    private mutating func setCol(face: CubeFace, col: Int, values: [Color]) {
        for i in 0..<size {
            faces[face]![i][col] = values[i]
        }
    }
}
