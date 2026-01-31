//
//  OLLView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct OLLView: View {
    let state: CubeState
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cellSize = size / 5 // 3x3 grid + padding for side stickers
            let spacing: CGFloat = 2
            let stickerGap: CGFloat = 1
            
            ZStack {
                // Main Up Face (3x3)
                VStack(spacing: spacing) {
                    ForEach(0..<3) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<3) { col in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(getColor(face: .up, row: row, col: col))
                                    .frame(width: cellSize, height: cellSize)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                
                // Side Stickers
                // Top (Back Face)
                HStack(spacing: spacing) {
                    ForEach(0..<3) { col in
                        Rectangle()
                            .fill(getColor(face: .back, row: 0, col: 2 - col)) // Reversing col for visual match if needed, verify logic
                            .frame(width: cellSize, height: cellSize * 0.2)
                    }
                }
                .offset(y: -(cellSize * 1.5 + cellSize * 0.1 + spacing + stickerGap))
                
                // Bottom (Front Face)
                HStack(spacing: spacing) {
                    ForEach(0..<3) { col in
                        Rectangle()
                            .fill(getColor(face: .front, row: 0, col: col))
                            .frame(width: cellSize, height: cellSize * 0.2)
                    }
                }
                .offset(y: (cellSize * 1.5 + cellSize * 0.1 + spacing + stickerGap))
                
                // Left (Left Face)
                VStack(spacing: spacing) {
                    ForEach(0..<3) { row in // Actually iterating cols of the side face which map to "row" here? No, face is 3x3.
                        // For the side view of the top layer, we look at the top row (row 0) of the Left face.
                        // But we want to display it vertically? No, usually OLL diagrams show the side sticker adjacent to the cell.
                        // Standard OLL diagrams:
                        //      [B][B][B]
                        //   [L][U][U][U][R]
                        //   [L][U][U][U][R]
                        //   [L][U][U][U][R]
                        //      [F][F][F]
                        
                        // So for Left face, we want its row 0, cols 0..2?
                        // Wait, Left Face Top Row is adjacent to Up Face Left Column.
                        // Let's assume we want to draw L[0][0], L[0][1], L[0][2] ?
                        // Detailed mapping:
                        // Up(0,0) is touching Left(0,2) and Back(0,2)
                        // Up(1,0) is touching Left(0,1)
                        // Up(2,0) is touching Left(0,0) and Front(0,0)
                        
                        // Let's use getSideColor helper to be safe
                         Rectangle()
                            .fill(getColor(face: .left, row: 0, col: 2 - row)) // 2-row to align with Up face top-to-bottom
                            .frame(width: cellSize * 0.2, height: cellSize)
                    }
                }
                .offset(x: -(cellSize * 1.5 + cellSize * 0.1 + spacing + stickerGap))
                
                // Right (Right Face)
                VStack(spacing: spacing) {
                    ForEach(0..<3) { row in
                        Rectangle()
                            .fill(getColor(face: .right, row: 0, col: 2 - row)) // 2-row?
                            // Up(0,2) touches Right(0,2) and Back(0,0)
                            // Up(1,2) touches Right(0,1)
                            // Up(2,2) touches Right(0,0) and Front(0,2)
                            // So top-to-bottom on screen corresponds to 2 -> 0 on Right face row 0?
                            // Let's stick with specific indices if possible or verify.
                            .frame(width: cellSize * 0.2, height: cellSize)
                    }
                }
                .offset(x: (cellSize * 1.5 + cellSize * 0.1 + spacing + stickerGap))
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    // Helper to extract color safely
    func getColor(face: CubeFace, row: Int, col: Int) -> Color {
        // We know size is 3 for OLL
        guard let faces = state.faces[face], faces.count > row, faces[row].count > col else {
            return .gray
        }
        return faces[row][col]
    }
}
