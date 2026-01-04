//
//  TimerView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var holdStartTime: Date?
    @State private var isHolding = false
    
    // Minimum hold time to start (in seconds)
    private let holdThreshold: TimeInterval = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                backgroundGradient
                
                // Main content
                VStack(spacing: 0) {
                    // Top section - Cube picker
                    topBar
                        .opacity(viewModel.timerState == .running ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.timerState)
                    
                    Spacer()
                    
                    // Center section - Timer & Scramble
                    centerContent
                    
                    Spacer()
                    
                    // Bottom section - Start prompt
                    bottomPrompt
                        .opacity(viewModel.timerState == .idle ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.timerState)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .gesture(timerGesture)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        ZStack {
            // Base dark color
            Color(red: 0.06, green: 0.06, blue: 0.08)
            
            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.08, blue: 0.15).opacity(0.6),
                    Color.clear,
                    Color(red: 0.08, green: 0.12, blue: 0.15).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Ambient glow based on timer state
            if viewModel.timerState == .ready {
                RadialGradient(
                    colors: [
                        Color(red: 0.2, green: 0.9, blue: 0.4).opacity(0.15),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 300
                )
                .transition(.opacity)
            }
            
            if viewModel.timerState == .running {
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 400
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.timerState)
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            CubeTypePicker(selectedType: $viewModel.selectedCubeType) { newType in
                viewModel.changeCubeType(to: newType)
            }
            
            Spacer()
            
            // Settings button placeholder
            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.06))
                    )
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Center Content
    
    private var centerContent: some View {
        VStack(spacing: 40) {
            // Scramble (hidden when running)
            if viewModel.timerState != .running {
                ScrambleView(
                    scramble: viewModel.currentScramble,
                    cubeType: viewModel.selectedCubeType,
                    onRefresh: viewModel.timerState == .idle ? {
                        viewModel.generateNewScramble()
                    } : nil
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            // Timer display
            TimerDisplayView(
                time: viewModel.displayTime,
                state: viewModel.timerState
            )
            .scaleEffect(viewModel.timerState == .running ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.timerState)
            
            // Last solve indicator (when stopped)
            if viewModel.timerState == .stopped {
                lastSolveIndicator
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.timerState)
    }
    
    private var lastSolveIndicator: some View {
        VStack(spacing: 8) {
            Text("Tap anywhere for next solve")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
    
    // MARK: - Bottom Prompt
    
    private var bottomPrompt: some View {
        StartTimerPrompt()
            .padding(.bottom, 40)
    }
    
    // MARK: - Gesture Handling
    
    private var timerGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                handleTouchDown()
            }
            .onEnded { _ in
                handleTouchUp()
            }
    }
    
    private func handleTouchDown() {
        switch viewModel.timerState {
        case .idle:
            // Start holding to prepare
            if holdStartTime == nil {
                holdStartTime = Date()
                isHolding = true
                
                // Check if held long enough after threshold
                DispatchQueue.main.asyncAfter(deadline: .now() + holdThreshold) {
                    if isHolding, let startTime = holdStartTime,
                       Date().timeIntervalSince(startTime) >= holdThreshold {
                        viewModel.prepareTimer()
                    }
                }
            }
            
        case .running:
            // Stop the timer immediately on touch
            viewModel.stopTimer()
            
        case .ready, .stopped:
            break
        }
    }
    
    private func handleTouchUp() {
        switch viewModel.timerState {
        case .ready:
            // Start the timer when released after being ready
            viewModel.startTimer()
            
        case .stopped:
            // Go back to idle for next solve
            viewModel.resetToIdle()
            
        case .idle, .running:
            break
        }
        
        // Reset hold state
        holdStartTime = nil
        isHolding = false
        
        // If we were preparing but released too early, go back to idle
        if viewModel.timerState == .idle {
            // Already idle, nothing to do
        }
    }
}

#Preview {
    TimerView()
}

