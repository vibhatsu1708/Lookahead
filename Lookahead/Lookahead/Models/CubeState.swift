
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
    var faces: [CubeFace: [[Color]]]
    let size: Int
    
    init(type: CubeType) {
        switch type {
        case .twoByTwo: self.size = 2
        case .threeByThree: self.size = 3
        case .fourByFour: self.size = 4
        case .fiveByFive: self.size = 5
        case .sixBySix: self.size = 6
        case .sevenBySeven: self.size = 7
        }
        
        var initialFaces: [CubeFace: [[Color]]] = [:]
        for face in CubeFace.allCases {
            initialFaces[face] = Array(repeating: Array(repeating: face.color, count: size), count: size)
        }
        self.faces = initialFaces
    }
    
    // Fallback init for size directly
    init(size: Int) {
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
        var mutableMove = move
        
        // Check for wide moves or slice count
        // Examples: "Rw", "3Rw", "u" (lowercase often means 2 layers or just inner slice, WCA standard uses Rw for 2 layers)
        
        let isWide = mutableMove.contains("w")
        var layerCount = 1
        
        // Check for numeric prefix e.g. "3Rw"
        if let firstChar = mutableMove.first, firstChar.isNumber {
            if let num = Int(String(firstChar)) {
                layerCount = num
                mutableMove.removeFirst()
            }
        } else if isWide {
            // "Rw" implies 2 layers by default in WCA for 4x4+ usually, 
            // but for 3x3 "Rw" is r (M' + R). 
            // For simplicity in standard scramblers:
            layerCount = 2
        }
        
        // Extract base face
        var baseChar = ""
        for char in mutableMove {
            if char.isLetter && char != "w" {
                baseChar = String(char)
                break
            }
        }
        
        let isPrime = mutableMove.contains("'")
        let isDouble = mutableMove.contains("2")
        let repeats = isDouble ? 2 : (isPrime ? 3 : 1)
        
        // If not wide, layerCount remains 1 (just the face)
        // If wide ("Rw"), it means layers 1...layerCount
        
        for _ in 0..<repeats {
            // For standard WCA wide moves, we rotate layers 1..layerCount together
            // If it's a standard move (not wide), we just rotate layer 1 (index 0)
            
            // Standard faces
            switch baseChar {
            case "R": rotateLayers(face: .right, count: layerCount)
            case "L": rotateLayers(face: .left, count: layerCount)
            case "U": rotateLayers(face: .up, count: layerCount)
            case "D": rotateLayers(face: .down, count: layerCount)
            case "F": rotateLayers(face: .front, count: layerCount)
            case "B": rotateLayers(face: .back, count: layerCount)
            default: break
            }
        }
    }
    
    // Rotate 1 or more layers starting from the face inward
    // count=1 means just the face layer. count=2 means face + adjacent slice, etc.
    private mutating func rotateLayers(face: CubeFace, count: Int) {
        
        // 1. Rotate the face grid itself if we are including the outermost layer
        // (technically if we supported inner-slice-only moves, we'd skip this, but WCA "Rw" includes R)
        if count > 0 {
            rotateFaceGrid(face)
        }
        
        // 2. Rotate the "rim" for each layer depth included
        for depth in 0..<count {
            rotateRim(face: face, depth: depth)
        }
    }
    
    private mutating func rotateFaceGrid(_ face: CubeFace) {
        guard let grid = faces[face] else { return }
        let n = grid.count
        var newGrid = grid
        for i in 0..<n {
            for j in 0..<n {
                // Clockwise rotation: (i, j) -> (j, n-1-i)
                newGrid[j][n - 1 - i] = grid[i][j]
            }
        }
        faces[face] = newGrid
    }
    
    // Rotates the adjacent stickers for a specific layer depth (0 = outermost)
    private mutating func rotateRim(face: CubeFace, depth: Int) {
        let n = size
        let last = n - 1
        let d = depth // depth index from the face side
        let invD = last - d // depth index from the opposite side
        
        switch face {
        case .right:
            let temp = getCol(face: .front, col: last - d)
            setCol(face: .front, col: last - d, values: getCol(face: .down, col: last - d))
            // Back is inverted relationship to Front/Down/Up in the array representation usually?
            // Let's standardise: 
            // Up face: row 0 is back, row N is front
            // Down face: row 0 is front, row N is back
            // Back face: row 0 is up, row N is down?
            // This depends on the unwrapping. 
            // Let's stick to the 3x3 logic generalized:
            // R affects: F(col N), U(col N), B(col 0 inv), D(col N)
            
            // From 3x3:
            // F -> U -> B(inv) -> D -> F
            // Wait, standard R: Up faces move to Back? No. 
            // R move: Front -> Up -> Back -> Down -> Front
            
            setCol(face: .front, col: last - d, values: getCol(face: .down, col: last - d))
            setCol(face: .down, col: last - d, values: getCol(face: .back, col: d).reversed()) 
            setCol(face: .back, col: d, values: getCol(face: .up, col: last - d).reversed())
            setCol(face: .up, col: last - d, values: temp)
            
        case .left:
            // L move: Front -> Down -> Back -> Up -> Front
            let temp = getCol(face: .front, col: d)
            setCol(face: .front, col: d, values: getCol(face: .up, col: d))
            setCol(face: .up, col: d, values: getCol(face: .back, col: last - d).reversed())
            setCol(face: .back, col: last - d, values: getCol(face: .down, col: d).reversed())
            setCol(face: .down, col: d, values: temp)
            
        case .up:
            // U move: Front -> Left -> Back -> Right -> Front
            let temp = getRow(face: .front, row: d)
            setRow(face: .front, row: d, values: getRow(face: .right, row: d))
            setRow(face: .right, row: d, values: getRow(face: .back, row: d))
            setRow(face: .back, row: d, values: getRow(face: .left, row: d))
            setRow(face: .left, row: d, values: temp)
            
        case .down:
            // D move: Front -> Right -> Back -> Left -> Front
            let temp = getRow(face: .front, row: last - d)
            setRow(face: .front, row: last - d, values: getRow(face: .left, row: last - d))
            setRow(face: .left, row: last - d, values: getRow(face: .back, row: last - d))
            setRow(face: .back, row: last - d, values: getRow(face: .right, row: last - d))
            setRow(face: .right, row: last - d, values: temp)
            
        case .front:
            // F move: Up -> Right -> Down -> Left -> Up
            let temp = getRow(face: .up, row: last - d)
            setRow(face: .up, row: last - d, values: getCol(face: .left, col: last - d).reversed())
            setCol(face: .left, col: last - d, values: getRow(face: .down, row: d))
            setRow(face: .down, row: d, values: getCol(face: .right, col: d).reversed())
            setCol(face: .right, col: d, values: temp)
            
        case .back:
            // B move: Up -> Left -> Down -> Right -> Up
            let temp = getRow(face: .up, row: d)
            setRow(face: .up, row: d, values: getCol(face: .right, col: last - d))
            setCol(face: .right, col: last - d, values: getRow(face: .down, row: last - d).reversed())
            setRow(face: .down, row: last - d, values: getCol(face: .left, col: d))
            setCol(face: .left, col: d, values: temp.reversed())
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
