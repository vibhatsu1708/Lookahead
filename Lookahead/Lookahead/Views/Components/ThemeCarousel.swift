//
//  ThemeCarousel.swift
//  Lookahead
//
//  Created by Vedant Mistry on 17/01/26.
//

import SwiftUI

struct ThemeCarousel: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    // Configuration
    private let itemWidth: CGFloat = 80
    private let spacing: CGFloat = 20
    
    // Gesture State
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    // Computed Constants
    private var snapDistance: CGFloat {
        itemWidth + spacing
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Selected Theme Name
            VStack(spacing: 4) {
                Text(themeManager.currentTheme.displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(themeManager.colors.light)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: themeManager.currentTheme)
                    .id("Name-\(themeManager.currentTheme.id)")
                
                Text(isDragging ? "Release to Select" : "Current Theme")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(themeManager.colors.light.opacity(0.5))
                    .animation(.easeInOut, value: isDragging)
            }
            .padding(.top, 10)
            
            // Carousel
            GeometryReader { geometry in
                let size = geometry.size
                let centerX = size.width / 2
                
                ZStack {
                    // Render a visible window of items (optimized range)
                    ForEach(-5...5, id: \.self) { index in
                        let logicalIndex = currentIndex + index
                        let themeIndex = getThemeIndex(for: logicalIndex)
                        let theme = AppTheme.allCases[themeIndex]
                        
                        let itemOffset = CGFloat(index) * snapDistance + dragOffset + accumulatedOffsetRemainder
                        let distanceFromCenter = itemOffset
                        
                        // Only render visual items within a reasonable range
                        if abs(distanceFromCenter) < size.width * 0.7 {
                            carouselItem(
                                theme: theme,
                                distanceFromCenter: distanceFromCenter,
                                centerX: centerX
                            )
                            .zIndex(zIndex(for: distanceFromCenter))
                            .offset(x: itemOffset)
                            .onTapGesture {
                                snapTo(index: logicalIndex)
                            }
                        }
                    }
                }
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle()) // Hit area for gesture
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.width
                            let translation = value.translation.width
                            finalizePosition(velocity: velocity, translation: translation)
                        }
                )
            }
            .frame(height: 180)
            .clipped()
        }    
        .onAppear {
            // Initialize offset to match current theme
            if let index = AppTheme.allCases.firstIndex(of: themeManager.currentTheme) {
                // We start at 0 offset representing index 0.
                // To show 'index', we must shift everything left by index counts
                offset = CGFloat(-index) * snapDistance
                lastOffset = offset
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func carouselItem(theme: AppTheme, distanceFromCenter: CGFloat, centerX: CGFloat) -> some View {
        let t = distanceFromCenter / (UIScreen.main.bounds.width / 2)
        let scale = 1.0 - (abs(t) * 0.3)
        
        let opacity = 1.0 - abs(t) * 0.6
        
        ZStack {
            // Circle Card
            Circle()
                .fill(theme.colors.backgroundGradient)
            
            // Border (Only alpha 1 if the theme if the current theme.)
            Circle()
                .strokeBorder(Color.white.opacity(theme == themeManager.currentTheme ? 1.0 : 0.3), lineWidth: 3)
        }
        .frame(width: itemWidth, height: itemWidth)
        .scaleEffect(scale)
        .opacity(opacity)
        .drawingGroup() // Optimize rendering performance
        .clipped()
    }
    
    // MARK: - Logic
    
    // Tracks the logical index the user has currently scrolled to (can be negative or huge positive)
    private var currentIndex: Int {
        Int(round(-offset / snapDistance))
    }
    
    // Calculated remainder to visually smooth out the drag
    private var accumulatedOffsetRemainder: CGFloat {
        let base = CGFloat(currentIndex) * snapDistance
        return (offset + base)
    }
    
    private var isDragging: Bool {
        dragOffset != 0
    }
    
    // Maps a logical infinite index to the actual array index (0..<count)
    private func getThemeIndex(for logicalIndex: Int) -> Int {
        let count = AppTheme.allCases.count
        let remainder = logicalIndex % count
        return remainder >= 0 ? remainder : remainder + count
    }
    
    private func zIndex(for distance: CGFloat) -> Double {
        -abs(distance)
    }
    
    private func finalizePosition(velocity: CGFloat, translation: CGFloat) {
        // CONTINUITY FIX:
        // Identify the exact visual offset at release
        let visualOffsetAtRelease = offset + translation
        
        // Immediately commit this visual offset to prevent jump when dragOffset becomes 0
        offset = visualOffsetAtRelease
        
        // MOMENTUM PHYSICS:
        // Increased multiplier for "fling" feel.
        // If velocity is high, we want to slide further.
        let momentumMultiplier: CGFloat = 0.6
        let projectedOffset = visualOffsetAtRelease + velocity * momentumMultiplier
        
        // Calculate nearest snap point based on the projected landing spot
        let index = round(-projectedOffset / snapDistance)
        let targetOffset = -index * snapDistance
        
        // Use an interpolating spring for the "settle" phase.
        // slightly higher response (0.5) creates a faster initial movement that slows down
        // lower damping (0.8) prevents it from feeling too stiff
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            offset = targetOffset
            lastOffset = offset
        }
        
        // Update Theme Logic
        let themeIndex = getThemeIndex(for: Int(index))
        let newTheme = AppTheme.allCases[themeIndex]
        
        // Haptics & Selection commit
        // We delay slightly to let the animation start, simulating the "snap" impact happening slightly after settling starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if themeManager.currentTheme != newTheme {
                HapticManager.shared.heavy()
                withAnimation(.easeInOut(duration: 0.2)) {
                    themeManager.setTheme(newTheme)
                }
            }
        }
    }
    
    private func snapTo(index: Int) {
        let targetOffset = CGFloat(-index) * snapDistance
        
        // Animate movement first
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            offset = targetOffset
            lastOffset = offset
        }
        
        let themeIndex = getThemeIndex(for: index)
        let newTheme = AppTheme.allCases[themeIndex]
        
        // Delay selection until visible snap occurs
        if themeManager.currentTheme != newTheme {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.2)) {
                    themeManager.setTheme(newTheme)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ThemeCarousel()
    }
}
