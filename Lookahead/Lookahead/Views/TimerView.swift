//
//  TimerView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var sessionManager: SessionManager
    @StateObject private var viewModel = TimerViewModel()
    @State private var holdStartTime: Date?
    @State private var isHolding = false
    @State private var showingCommentSheet = false
    
    // Minimum hold time to start (in seconds)
    private let holdThreshold: TimeInterval = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                backgroundGradient
                
                // Main content
                VStack(spacing: 0) {
                    // Top section - Session picker & Cube picker
                    topBar
                        .opacity(viewModel.timerState == .running ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.timerState)
                    
                    Spacer()
                    
                    // Center section - Timer & Scramble
                    centerContent
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .gesture(timerGesture)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            syncWithCurrentSession()
        }
        .onChange(of: sessionManager.currentSession) { _, _ in
            syncWithCurrentSession()
        }
        .sheet(isPresented: $showingCommentSheet) {
            if let solve = viewModel.lastSavedSolve {
                CommentSheet(solve: solve)
            }
        }
    }
    
    private func syncWithCurrentSession() {
        viewModel.syncWithSession(sessionManager.currentSession)
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
        VStack(spacing: 12) {
            HStack {
                SessionPicker(sessionManager: sessionManager)
                
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
            
            // Cube type picker (synced with session)
            HStack {
                CubeTypePicker(selectedType: $viewModel.selectedCubeType) { newType in
                    viewModel.changeCubeType(to: newType)
                    // Update session's cube type
                    if let session = sessionManager.currentSession {
                        sessionManager.updateSessionCubeType(session, to: newType)
                    }
                }
                
                Spacer()
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
            
            // Prompt text or action buttons
            if viewModel.timerState == .stopped {
                solveActionButtons
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                timerPromptText
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.timerState)
    }
    
    private var timerPromptText: some View {
        Group {
            switch viewModel.timerState {
            case .idle:
                Text("Hold to start")
            case .ready:
                Text("Release to start")
            case .running:
                Text("")
            case .stopped:
                Text("")
            }
        }
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .foregroundStyle(.white.opacity(0.4))
        .animation(.easeInOut(duration: 0.2), value: viewModel.timerState)
    }
    
    // MARK: - Solve Action Buttons
    
    private var solveActionButtons: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                // Flag
                SolveActionButton(
                    icon: viewModel.isLastSolveFlagged ? "flag.fill" : "flag",
                    isSelected: viewModel.isLastSolveFlagged,
                    color: .yellow
                ) {
                    viewModel.toggleFlag(context: viewContext)
                }
                
                // +2
                SolveActionButton(
                    icon: "plus.circle",
                    label: "+2",
                    isSelected: viewModel.lastSolvePenalty == .plusTwo,
                    color: .orange
                ) {
                    viewModel.togglePenalty(.plusTwo, context: viewContext)
                }
                
                // DNF
                SolveActionButton(
                    icon: "xmark.circle",
                    label: "DNF",
                    isSelected: viewModel.lastSolvePenalty == .dnf,
                    color: .red
                ) {
                    viewModel.togglePenalty(.dnf, context: viewContext)
                }
                
                // Comment
                SolveActionButton(
                    icon: viewModel.lastSolveHasComment ? "text.bubble.fill" : "text.bubble",
                    isSelected: viewModel.lastSolveHasComment,
                    color: .blue
                ) {
                    showingCommentSheet = true
                }
                
                // Delete
                SolveActionButton(
                    icon: "trash",
                    isSelected: false,
                    color: .red
                ) {
                    if viewModel.deleteLastSolve(context: viewContext) {
                        sessionManager.refreshSessions()
                    }
                }
            }
            
            Text("Tap anywhere for next solve")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
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
            viewModel.stopTimer(context: viewContext, session: sessionManager.currentSession)
            sessionManager.refreshSessions()
            
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
    }
}

// MARK: - Solve Action Button

struct SolveActionButton: View {
    let icon: String
    var label: String? = nil
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                
                if let label = label {
                    Text(label)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
            }
            .foregroundStyle(isSelected ? .white : color)
            .frame(width: 52, height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? color : color.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Comment Sheet

struct CommentSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var solve: SolveEntity
    @State private var comment: String = ""
    
    private let maxCommentLength = 100
    
    init(solve: SolveEntity) {
        self.solve = solve
        _comment = State(initialValue: solve.comment ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(comment.count)/\(maxCommentLength)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(comment.count >= maxCommentLength ? .orange : .white.opacity(0.3))
                    }
                    
                    // Text field
                    TextField("Add a comment...", text: $comment, axis: .vertical)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(4...6)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .onChange(of: comment) { _, newValue in
                            if newValue.count > maxCommentLength {
                                comment = String(newValue.prefix(maxCommentLength))
                            }
                        }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        solve.setComment(comment.isEmpty ? nil : comment)
                        try? viewContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(Color(red: 0.06, green: 0.06, blue: 0.08), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.height(250)])
        .preferredColorScheme(.dark)
    }
}

#Preview {
    TimerView(sessionManager: SessionManager(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
