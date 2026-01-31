//
//  AlgorithmDetailSheet.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct AlgorithmDetailSheet: View {
    let algorithmCase: AlgorithmCase
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.colors.darkest.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        cubeHeader
                        
                        VStack(alignment: .leading, spacing: 16) {
                            headerText
                            setupMovesSection
                            mainAlgorithmSection
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var cubeHeader: some View {
        ZStack {
            Color.black.opacity(0.2)
            Cube3DView(state: getSetupState())
        }
        .frame(height: 300)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.colors.light.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private var headerText: some View {
        Text(algorithmCase.name)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(themeManager.colors.light)
    }
    
    private var setupMovesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Setup Moves")
                .font(.subheadline)
                .foregroundStyle(themeManager.colors.light)
            
            Text(algorithmCase.setupMoves)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundStyle(themeManager.colors.light.opacity(0.6))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.colors.light.opacity(0.05))
                )
        }
    }

    private var mainAlgorithmSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Algorithm")
                .font(.subheadline)
                .foregroundStyle(themeManager.colors.light)
            
            Text(algorithmCase.algorithm)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundStyle(themeManager.colors.light.opacity(0.8))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.colors.light.opacity(0.05))
                )
        }
    }
    

    
    private func getSetupState() -> CubeState {
        var state = CubeState(type: .threeByThree)
        state.apply(moves: algorithmCase.setupMoves)
        return state
    }
}
