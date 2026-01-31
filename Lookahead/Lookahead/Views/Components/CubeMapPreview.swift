
//
//  CubeMapPreview.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct CubeMapPreview: View {
    let state: CubeState
    
    // Scale factor for the grid
    let cellSize: CGFloat = 12
    let spacing: CGFloat = 2
    
    var body: some View {
        VStack(spacing: spacing) {
            // First row: just U face (centered relative to L, F, R, B)
            // Layout:
            //       [U]
            //    [L][F][R][B]
            //       [D]
            
            // Top Row (Up)
            HStack(spacing: spacing) {
                Color.clear
                    .frame(width: faceSize, height: faceSize)
                FaceView(grid: state.faces[.up]!, cellSize: cellSize, spacing: spacing)
                Color.clear
                    .frame(width: faceSize, height: faceSize)
                Color.clear
                    .frame(width: faceSize, height: faceSize)
            }
            
            // Middle Row (Left, Front, Right, Back)
            HStack(spacing: spacing) {
                FaceView(grid: state.faces[.left]!, cellSize: cellSize, spacing: spacing)
                FaceView(grid: state.faces[.front]!, cellSize: cellSize, spacing: spacing)
                FaceView(grid: state.faces[.right]!, cellSize: cellSize, spacing: spacing)
                FaceView(grid: state.faces[.back]!, cellSize: cellSize, spacing: spacing)
            }
            
            // Bottom Row (Down)
            HStack(spacing: spacing) {
                Color.clear
                    .frame(width: faceSize, height: faceSize)
                FaceView(grid: state.faces[.down]!, cellSize: cellSize, spacing: spacing)
                Color.clear
                    .frame(width: faceSize, height: faceSize)
                Color.clear
                    .frame(width: faceSize, height: faceSize)
            }
        }
        .padding(8)
        .background(Color(white: 0.1))
        .cornerRadius(8)
    }
    
    private var faceSize: CGFloat {
        CGFloat(state.size) * cellSize + CGFloat(state.size - 1) * spacing
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

#Preview {
    var state = CubeState(size: 3)
    // Apply a simple scramble to test: R U R' U'
    state.apply(moves: "R U R' U'")
    return CubeMapPreview(state: state)
}
