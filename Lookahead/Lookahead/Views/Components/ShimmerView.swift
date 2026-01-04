//
//  ShimmerView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

enum ShimmerDirection {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
    
    var startPoint: UnitPoint {
        switch self {
        case .leftToRight: return .leading
        case .rightToLeft: return .trailing
        case .topToBottom: return .top
        case .bottomToTop: return .bottom
        }
    }
    
    var endPoint: UnitPoint {
        switch self {
        case .leftToRight: return .trailing
        case .rightToLeft: return .leading
        case .topToBottom: return .bottom
        case .bottomToTop: return .top
        }
    }
}

struct ShimmerView: View {
    let direction: ShimmerDirection
    var isActive: Bool = true
    var baseColor: Color = Color.white.opacity(0.15)
    var shimmerColor: Color = Color.white.opacity(0.4)
    var duration: Double = 1.5
    var cornerRadius: CGFloat = 8
    
    @State private var animationPhase: CGFloat = -1
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(baseColor)
                .overlay(
                    shimmerGradient
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        )
                        .opacity(isActive ? 1 : 0)
                )
                .onChange(of: isActive) { _, newValue in
                    if newValue {
                        // Reset and start animation
                        animationPhase = -1
                        withAnimation(
                            .linear(duration: duration)
                            .repeatForever(autoreverses: false)
                        ) {
                            animationPhase = 2
                        }
                    }
                }
                .onAppear {
                    if isActive {
                        withAnimation(
                            .linear(duration: duration)
                            .repeatForever(autoreverses: false)
                        ) {
                            animationPhase = 2
                        }
                    }
                }
        }
    }
    
    private var shimmerGradient: some View {
        GeometryReader { geometry in
            let isHorizontal = direction == .leftToRight || direction == .rightToLeft
            let size = isHorizontal ? geometry.size.width : geometry.size.height
            
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: shimmerColor, location: 0.3),
                    .init(color: shimmerColor, location: 0.5),
                    .init(color: .clear, location: 0.8)
                ],
                startPoint: direction.startPoint,
                endPoint: direction.endPoint
            )
            .frame(
                width: isHorizontal ? size * 0.6 : nil,
                height: isHorizontal ? nil : size * 0.6
            )
            .offset(
                x: isHorizontal ? shimmerOffset(size: size, phase: animationPhase, direction: direction) : 0,
                y: isHorizontal ? 0 : shimmerOffset(size: size, phase: animationPhase, direction: direction)
            )
        }
        .clipped()
    }
    
    private func shimmerOffset(size: CGFloat, phase: CGFloat, direction: ShimmerDirection) -> CGFloat {
        let totalDistance = size * 1.6
        let baseOffset = phase * totalDistance - size * 0.3
        
        switch direction {
        case .leftToRight, .topToBottom:
            return baseOffset
        case .rightToLeft, .bottomToTop:
            return -baseOffset
        }
    }
}

// MARK: - View Modifier for easy application

struct ShimmerModifier: ViewModifier {
    let direction: ShimmerDirection
    var isActive: Bool = true
    var baseColor: Color = Color.white.opacity(0.15)
    var shimmerColor: Color = Color.white.opacity(0.4)
    var duration: Double = 1.5
    var cornerRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .background(
                ShimmerView(
                    direction: direction,
                    isActive: isActive,
                    baseColor: baseColor,
                    shimmerColor: shimmerColor,
                    duration: duration,
                    cornerRadius: cornerRadius
                )
            )
    }
}

extension View {
    func shimmer(
        direction: ShimmerDirection = .leftToRight,
        isActive: Bool = true,
        baseColor: Color = Color.white.opacity(0.15),
        shimmerColor: Color = Color.white.opacity(0.4),
        duration: Double = 1.5,
        cornerRadius: CGFloat = 8
    ) -> some View {
        modifier(ShimmerModifier(
            direction: direction,
            isActive: isActive,
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            duration: duration,
            cornerRadius: cornerRadius
        ))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 30) {
            // Active shimmer
            ShimmerView(direction: .leftToRight, isActive: true)
                .frame(width: 120, height: 50)
            
            // Inactive shimmer (just shows base color)
            ShimmerView(direction: .leftToRight, isActive: false)
                .frame(width: 120, height: 50)
            
            // Using modifier
            Text(".42")
                .font(.system(size: 40, weight: .light, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .shimmer(direction: .leftToRight, isActive: true, cornerRadius: 12)
        }
    }
}
