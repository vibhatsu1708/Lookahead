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
    
    var body: some View {
        VStack(spacing: 16) {
            // Scramble text
            Text(scramble)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 10)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isAnimating)
            
            // Refresh button
            if let onRefresh = onRefresh {
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
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
        .onChange(of: scramble) { _, _ in
            isAnimating = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
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

