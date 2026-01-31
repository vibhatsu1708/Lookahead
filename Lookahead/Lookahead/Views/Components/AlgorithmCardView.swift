//
//  AlgorithmCardView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct AlgorithmCardView: View {
    let algorithmCase: AlgorithmCase
    let category: AlgorithmCategory
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Preview
            ZStack {
                Color.black.opacity(0.2)
                
                if category == .oll {
                    OLLView(state: getSetupState())
                        .padding(8)
                } else {
                    Cube3DView(state: getSetupState(), interactive: false)
                }
            }
            .aspectRatio(1.2, contentMode: .fit) // Keep valid aspect ratio
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.colors.light.opacity(0.1), lineWidth: 1)
            )
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                Text(algorithmCase.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(themeManager.colors.light)
                    .lineLimit(1)
                
                Text(algorithmCase.algorithm)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(themeManager.colors.light.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        // Removed fixed frame(width: 160) to allow flexibility in grids
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.dark.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    themeManager.colors.light.opacity(0.2),
                                    themeManager.colors.light.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func getSetupState() -> CubeState {
        var state = CubeState(type: .threeByThree)
        state.apply(moves: algorithmCase.setupMoves)
        return state
    }
}
