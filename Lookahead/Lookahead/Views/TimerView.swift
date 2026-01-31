//
//  TimerView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var sessionManager: SessionManager
    @StateObject private var viewModel = TimerViewModel()
    @State private var holdStartTime: Date?
    @State private var isHolding = false
    @State private var showingCommentSheet = false
    @ObservedObject var themeManager = ThemeManager.shared
    
    @AppStorage("hideTimer") private var hideTimer = false
    @AppStorage("inspectionEnabled") private var inspectionEnabled = false
    

    
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
            // Sync settings
            viewModel.inspectionEnabled = inspectionEnabled
        }
        .onChange(of: inspectionEnabled) { _, newValue in
            viewModel.inspectionEnabled = newValue
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive || newPhase == .background {
                // Cancel holding if app goes background
                if isHolding {
                    isHolding = false
                    holdStartTime = nil
                }
                // If we were ready to start, go back to idle to prevent accidental start on resume
                if viewModel.timerState == .ready {
                    viewModel.resetToIdle()
                }
            }
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
        GeometryReader { geometry in
            ZStack {
                // Dynamic Theme Background
                themeManager.colors.complexGradient
                
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
                
                if viewModel.timerState == .inspection {
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 250
                    )
                    .transition(.opacity)
                }
                
                if viewModel.timerState == .running {
                    RadialGradient(
                        colors: [
                            themeManager.colors.light.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.timerState)
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack(spacing: 8) {
            SessionPicker(sessionManager: sessionManager)
            
            // Divider
            Capsule()
                .fill(.white.opacity(0.1))
                .frame(width: 1, height: 20)
            
            CubeTypePicker(selectedType: $viewModel.selectedCubeType) { newType in
                viewModel.changeCubeType(to: newType)
                // Update session's cube type
                if let session = sessionManager.currentSession {
                    sessionManager.updateSessionCubeType(session, to: newType)
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.white.opacity(0.08))
                .overlay(
                    Capsule()
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
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
            } else if hideTimer {
                // Show "Solving..." or similar visual when hidden
                Text("Solving...")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundStyle(themeManager.colors.light.opacity(0.3))
            }
            
            // Timer display
            if !hideTimer || viewModel.timerState != .running {
                TimerDisplayView(
                    time: viewModel.displayTime,
                    state: viewModel.timerState
                )
                .scaleEffect(viewModel.timerState == .running ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.timerState)
            }
            
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
            case .inspection:
                Text("Inspection")
            case .running:
                Text("")
            case .stopped:
                Text("")
            }
        }
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .foregroundStyle(themeManager.colors.light.opacity(0.4))
        .animation(.easeInOut(duration: 0.2), value: viewModel.timerState)
    }
    
    // MARK: - Solve Action Buttons
    
    private var solveActionButtons: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
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
                
                // +2
                SolveActionButton(
                    icon: "02.circle",
                    isSelected: viewModel.lastSolvePenalty == .plusTwo,
                    color: .orange
                ) {
                    viewModel.togglePenalty(.plusTwo, context: viewContext)
                }
                
                // DNF
                SolveActionButton(
                    icon: "xmark.circle",
                    isSelected: viewModel.lastSolvePenalty == .dnf,
                    color: .red
                ) {
                    viewModel.togglePenalty(.dnf, context: viewContext)
                }
                
                // Flag
                SolveActionButton(
                    icon: viewModel.isLastSolveFlagged ? "flag.fill" : "flag",
                    isSelected: viewModel.isLastSolveFlagged,
                    color: .yellow
                ) {
                    viewModel.toggleFlag(context: viewContext)
                }
                
                // Comment
                SolveActionButton(
                    icon: viewModel.lastSolveHasComment ? "text.bubble.fill" : "text.bubble",
                    isSelected: viewModel.lastSolveHasComment,
                    color: .blue
                ) {
                    showingCommentSheet = true
                }
            }
            
            Text("Tap anywhere for next solve")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(themeManager.colors.light.opacity(0.4))
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
        case .stopped:
            // When stopped, a new touch resets the timer and starts the hold process for the next solve
            viewModel.resetToIdle()
            startHoldCheck()
            
        case .idle:
            startHoldCheck()
            
        case .inspection:
            startHoldCheck()
            
        case .running:
            // Stop the timer immediately on touch
            viewModel.stopTimer(context: viewContext, session: sessionManager.currentSession)
            sessionManager.refreshSessions()
            
        case .ready:
            break
        }
    }
    
    private func startHoldCheck() {
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
    }
    
    private func handleTouchUp() {
        switch viewModel.timerState {
        case .ready:
            // Start the timer (or inspection) when released after being ready
            viewModel.triggerPhaseChange()
            
        case .stopped, .idle, .inspection, .running:
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
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(isSelected ? color : .white)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Comment Sheet

struct CommentSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var solve: SolveEntity
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var comment: String = ""
    
    private let maxCommentLength = 100
    
    init(solve: SolveEntity) {
        self.solve = solve
        _comment = State(initialValue: solve.comment ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.colors.complexGradient
                
                VStack(spacing: 20) {
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(comment.count)/\(maxCommentLength)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(comment.count >= maxCommentLength ? .orange : themeManager.colors.light.opacity(0.3))
                    }
                    
                    // Text field
                    TextField("Add a comment...", text: $comment, axis: .vertical)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(themeManager.colors.light)
                        .lineLimit(4...6)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(themeManager.colors.light.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(themeManager.colors.light.opacity(0.1), lineWidth: 1)
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
                    .foregroundStyle(themeManager.colors.light.opacity(0.7))
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
            .toolbarBackground(themeManager.colors.darkest, for: .navigationBar)
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
