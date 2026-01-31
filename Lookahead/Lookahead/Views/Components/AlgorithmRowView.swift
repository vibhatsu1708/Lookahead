//
//  AlgorithmRowView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct AlgorithmRowView: View {
    let algorithmCase: AlgorithmCase
    let category: AlgorithmCategory
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Mini Preview
            ZStack {
                Color.black.opacity(0.1)
                
                if category == .oll {
                    OLLView(state: getSetupState())
                        .padding(4) // Add some padding for OLL view side stickers
                } else {
                    Cube3DView(state: getSetupState(), interactive: false)
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.colors.light.opacity(0.2), lineWidth: 1)
            )
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(algorithmCase.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.colors.light)
                
                Text(algorithmCase.algorithm)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(themeManager.colors.light.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(themeManager.colors.light.opacity(0.3))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private func getSetupState() -> CubeState {
        var state = CubeState(type: .threeByThree)
        state.apply(moves: algorithmCase.setupMoves)
        return state
    }
}
