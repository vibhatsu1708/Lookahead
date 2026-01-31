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
                Color.black.opacity(0.1)
                
                if category == .oll {
                    OLLView(state: getSetupState())
                        .padding(8)
                } else {
                    Cube3DView(state: getSetupState(), interactive: false)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.colors.light.opacity(0.1), lineWidth: 1)
            )
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(algorithmCase.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(themeManager.colors.light)
                    .lineLimit(1)
                
                Text(algorithmCase.algorithm)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(themeManager.colors.light.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .frame(width: 160) 
        .background(themeManager.colors.dark.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.colors.light.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func getSetupState() -> CubeState {
        var state = CubeState(type: .threeByThree)
        state.apply(moves: algorithmCase.setupMoves)
        return state
    }
}
