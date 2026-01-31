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
                            mainAlgorithmSection
                            alternativesSection
                            
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
    
    @ViewBuilder
    private var alternativesSection: some View {
        if let alternatives = algorithmCase.alternatives, !alternatives.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Alternatives")
                    .font(.subheadline)
                    .foregroundStyle(themeManager.colors.light)
                
                ForEach(alternatives, id: \.self) { alt in
                    Text(alt)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(themeManager.colors.light.opacity(0.8))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.colors.light.opacity(0.03))
                        )
                }
            }
        }
    }
    
    private func getSetupState() -> CubeState {
        var state = CubeState(type: .threeByThree)
        state.apply(moves: algorithmCase.setupMoves)
        return state
    }
}
