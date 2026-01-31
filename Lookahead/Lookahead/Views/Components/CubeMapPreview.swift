
//
//  CubeMapPreview.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct CubeMapPreview: View {
    let state: CubeState
    
    init(state: CubeState) {
        self.state = state
    }
    
    // Scale factor for the grid
    // Fixed face size logic
    // We want the face to always be around 40pt regardless of grid size
    private var baseFaceSize: CGFloat = 40
    private let spacing: CGFloat = 2
    
    // Dynamically calculate cell size to fit the baseFaceSize
    private var cellSize: CGFloat {
        // formula: size * cell + (size - 1) * spacing = faceSize
        // size * cell = faceSize - (size - 1) * spacing
        // cell = (faceSize - (size - 1) * spacing) / size
        
        // Ensure size is at least 1 to avoid division by zero
        let n = CGFloat(max(1, state.size))
        let totalSpacing = (n - 1) * spacing
        let availableSpace = max(0, baseFaceSize - totalSpacing)
        return availableSpace / n
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            // first row
            HStack(spacing: spacing) {
                Color.clear.frame(width: baseFaceSize, height: baseFaceSize)
                FaceView(grid: state.faces[.up]!, cellSize: cellSize, spacing: spacing)
                Color.clear.frame(width: baseFaceSize, height: baseFaceSize)
                Color.clear.frame(width: baseFaceSize, height: baseFaceSize)
            }
            
            // middle row
            HStack(spacing: spacing) {
                FaceView(grid: state.faces[.left]!, cellSize: cellSize, spacing: spacing)
                FaceView(grid: state.faces[.front]!, cellSize: cellSize, spacing: spacing)
                FaceView(grid: state.faces[.right]!, cellSize: cellSize, spacing: spacing)
                FaceView(grid: state.faces[.back]!, cellSize: cellSize, spacing: spacing)
            }
            
            // bottom row
            HStack(spacing: spacing) {
                Color.clear.frame(width: baseFaceSize, height: baseFaceSize)
                FaceView(grid: state.faces[.down]!, cellSize: cellSize, spacing: spacing)
                Color.clear.frame(width: baseFaceSize, height: baseFaceSize)
                Color.clear.frame(width: baseFaceSize, height: baseFaceSize)
            }
        }
        .padding(8)
        .background(Color(white: 0.1))
        .cornerRadius(8)
        // Ensure the total view size is consistent
        .frame(width: (4 * baseFaceSize) + (3 * spacing) + 16, height: (3 * baseFaceSize) + (2 * spacing) + 16)
    }
}

struct FaceView: View {
    let grid: [[Color]]
    let cellSize: CGFloat
    let spacing: CGFloat
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<grid.count, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<grid[row].count, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(grid[row][col])
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
}
//
//#Preview {
//    var state = CubeState(size: 3)
//    // Apply a simple scramble to test: R U R' U'
//    state.apply(moves: "R U R' U'")
//    return CubeMapPreview(state: state)
//}
