//
//  HistoryView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var sessionManager: SessionManager
    
    @State private var selectedCubeFilter: CubeType? = nil
    @State private var selectedSolve: SolveEntity? = nil
    @State private var isGridView = false
    
    private var currentSessionSolves: [SolveEntity] {
        sessionManager.currentSession?.solvesArray ?? []
    }
    
    private var filteredSolves: [SolveEntity] {
        if let filter = selectedCubeFilter {
            return currentSessionSolves.filter { $0.cubeType == filter.rawValue }
        }
        return currentSessionSolves
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.06, green: 0.06, blue: 0.08)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Session picker
                sessionPickerRow
                
                // Filter chips
                filterChips
                
                // Solves list
                if filteredSolves.isEmpty {
                    emptyState
                } else {
                    if isGridView {
                        solvesGrid
                    } else {
                        solvesList
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedSolve) { solve in
            SolveDetailSheet(solve: solve)
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("History")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("\(currentSessionSolves.count) solves")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            // View mode toggle button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isGridView.toggle()
                }
            } label: {
                Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 30)
        .padding(.bottom, 12)
    }
    
    // MARK: - Session Picker Row
    
    private var sessionPickerRow: some View {
        HStack {
            SessionPicker(sessionManager: sessionManager)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: "All", isSelected: selectedCubeFilter == nil) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCubeFilter = nil
                    }
                }
                
                ForEach(CubeType.allCases) { cubeType in
                    FilterChip(title: cubeType.displayName, isSelected: selectedCubeFilter == cubeType) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCubeFilter = cubeType
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 16)
    }
    
    private var statsSummary: some View {
        StatsSummaryView(solves: filteredSolves)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.2))
            
            Text("No solves yet")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
            
            Text("Complete a solve to see it here")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.3))
            
            Spacer()
        }
    }
    
    // MARK: - Solves List
    
    private var solvesList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Stats summary at the top of scrollable content
                statsSummary
                    .padding(.bottom, 20)
                
                LazyVStack(spacing: 12) {
                    ForEach(filteredSolves, id: \.id) { solve in
                        SolveRow(solve: solve)
                            .onTapGesture {
                                selectedSolve = solve
                            }
                            .contextMenu {
                                // Penalty options
                                Menu {
                                    Button {
                                        updatePenalty(solve, to: .none)
                                    } label: {
                                        Label("OK", systemImage: solve.penaltyType == .none ? "checkmark" : "")
                                    }
                                    
                                    Button {
                                        updatePenalty(solve, to: .plusTwo)
                                    } label: {
                                        Label("+2", systemImage: solve.penaltyType == .plusTwo ? "checkmark" : "")
                                    }
                                    
                                    Button {
                                        updatePenalty(solve, to: .dnf)
                                    } label: {
                                        Label("DNF", systemImage: solve.penaltyType == .dnf ? "checkmark" : "")
                                    }
                                } label: {
                                    Label("Penalty", systemImage: "exclamationmark.triangle")
                                }
                                
                                // Flag toggle
                                Button {
                                    toggleFlag(solve)
                                } label: {
                                    Label(
                                        solve.isFlagged ? "Unflag" : "Flag",
                                        systemImage: solve.isFlagged ? "flag.slash" : "flag"
                                    )
                                }
                                
                                Divider()
                                
                                // Delete
                                Button(role: .destructive) {
                                    deleteSolve(solve)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Solves Grid
    
    private var solvesGrid: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Stats summary at the top of scrollable content
                statsSummary
                    .padding(.bottom, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(filteredSolves, id: \.id) { solve in
                        CompactSolveCard(solve: solve)
                            .onTapGesture {
                                selectedSolve = solve
                            }
                            .contextMenu {
                                // Penalty options
                                Menu {
                                    Button {
                                        updatePenalty(solve, to: .none)
                                    } label: {
                                        Label("OK", systemImage: solve.penaltyType == .none ? "checkmark" : "")
                                    }
                                    
                                    Button {
                                        updatePenalty(solve, to: .plusTwo)
                                    } label: {
                                        Label("+2", systemImage: solve.penaltyType == .plusTwo ? "checkmark" : "")
                                    }
                                    
                                    Button {
                                        updatePenalty(solve, to: .dnf)
                                    } label: {
                                        Label("DNF", systemImage: solve.penaltyType == .dnf ? "checkmark" : "")
                                    }
                                } label: {
                                    Label("Penalty", systemImage: "exclamationmark.triangle")
                                }
                                
                                // Flag toggle
                                Button {
                                    toggleFlag(solve)
                                } label: {
                                    Label(
                                        solve.isFlagged ? "Unflag" : "Flag",
                                        systemImage: solve.isFlagged ? "flag.slash" : "flag"
                                    )
                                }
                                
                                Divider()
                                
                                // Delete
                                Button(role: .destructive) {
                                    deleteSolve(solve)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
    }

    
    // MARK: - Helpers
    
    private func updatePenalty(_ solve: SolveEntity, to penalty: SolvePenalty) {
        withAnimation {
            solve.penaltyType = penalty
            try? viewContext.save()
        }
    }
    
    private func toggleFlag(_ solve: SolveEntity) {
        withAnimation {
            solve.isFlagged.toggle()
            try? viewContext.save()
        }
    }
    
    private func deleteSolve(_ solve: SolveEntity) {
        withAnimation {
            viewContext.delete(solve)
            try? viewContext.save()
            sessionManager.refreshSessions()
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .black : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? .white : .white.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Solve Row

struct SolveRow: View {
    @ObservedObject var solve: SolveEntity
    
    private var timeColor: Color {
        switch solve.penaltyType {
        case .dnf:
            return .red.opacity(0.8)
        case .plusTwo:
            return .orange
        case .none:
            return .white
        }
    }
    
    private var formattedDate: String {
        guard let date = solve.date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Flag indicator
            if solve.isFlagged {
                Image(systemName: "flag.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.yellow)
            }
            
            // Time
            Text(solve.formattedTime)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timeColor)
            
            // Comment indicator
            if solve.comment != nil && !solve.comment!.isEmpty {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            // Cube type & date
            VStack(alignment: .trailing, spacing: 4) {
                Text(solve.cubeType ?? "3x3")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                
                Text(formattedDate)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(solve.isFlagged ? .yellow.opacity(0.2) : .white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Compact Solve Card

struct CompactSolveCard: View {
    @ObservedObject var solve: SolveEntity
    
    private var timeColor: Color {
        switch solve.penaltyType {
        case .dnf:
            return .red.opacity(0.8)
        case .plusTwo:
            return .orange
        case .none:
            return .white
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Flag indicator at top
            HStack {
                if solve.isFlagged {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                }
                
                Spacer()
                
                // Comment indicator
                if solve.comment != nil && !solve.comment!.isEmpty {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(height: 12)
            
            // Time (main content)
            Text(solve.formattedTime)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Cube type
            Text(solve.cubeType ?? "3x3")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fill)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(solve.isFlagged ? .yellow.opacity(0.2) : .white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}


#Preview {
    HistoryView(sessionManager: SessionManager(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
