//
//  ScrambleView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct ScrambleView: View {
    let scramble: String
    let cubeType: CubeType
    var onRefresh: (() -> Void)?
    
    @State private var isAnimating = false
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var showing3DPreview = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Scramble text
            Text(scramble)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(themeManager.colors.light)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .contentShape(Rectangle()) // Make entire area tappable
                .onTapGesture {
                    showing3DPreview = true
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 10)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isAnimating)
            
            // Refresh & Preview buttons
            if let onRefresh = onRefresh {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isAnimating = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            onRefresh()
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isAnimating = true
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                            Text("New Scramble")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(themeManager.colors.light.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(themeManager.colors.light.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        // Create state and show
                        var state = CubeState(type: cubeType)
                        state.apply(moves: scramble)
                        FloatingPreviewManager.shared.toggle(with: state)
                    }) {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(themeManager.colors.light.opacity(0.6))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(themeManager.colors.light.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showing3DPreview) {
            NavigationStack {
                ZStack {
                   themeManager.colors.darkest.ignoresSafeArea()
                   
                   Cube3DView(state: getCubeState())
                        .ignoresSafeArea()
                }
                .navigationTitle("3D Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showing3DPreview = false
                        }
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
            }
            .presentationDetents([.medium, .large])
        }
        .onChange(of: scramble) { _, newValue in
            // If floating preview is active, update it
            if FloatingPreviewManager.shared.currentCubeState != nil {
                var state = CubeState(type: cubeType)
                state.apply(moves: newValue)
                FloatingPreviewManager.shared.show(with: state)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
        .onDisappear {
            FloatingPreviewManager.shared.hide()
        }
        .onChange(of: scramble) { _, _ in
            isAnimating = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private func getCubeState() -> CubeState {
        var state = CubeState(type: cubeType)
        state.apply(moves: scramble)
        return state
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrambleView(
            scramble: "R U R' U' R' F R2 U' R' U' R U R' F'",
            cubeType: .threeByThree,
            onRefresh: {}
        )
    }
}

