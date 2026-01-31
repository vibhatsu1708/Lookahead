//
//  SolveDetailSheet.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct SolveDetailSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var solve: SolveEntity
    @ObservedObject var themeManager = ThemeManager.shared
    
    @State private var comment: String = ""
    @State private var isFlagged: Bool = false
    @State private var selectedPenalty: SolvePenalty = .none
    
    private let maxCommentLength = 100
    
    init(solve: SolveEntity) {
        self.solve = solve
        _comment = State(initialValue: solve.comment ?? "")
        _isFlagged = State(initialValue: solve.isFlagged)
        _selectedPenalty = State(initialValue: solve.penaltyType)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.colors.complexGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time display
                        timeSection
                        
                        // Scramble
                        scrambleSection
                        
                        // Penalty selector
                        penaltySection
                        
                        // Flag toggle
                        flagSection
                        
                        // Comment
                        commentSection
                        
                        // Metadata
                        metadataSection
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Solve Details")
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
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(themeManager.colors.darkest, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Time Section
    
    private var timeSection: some View {
        VStack(spacing: 8) {
            Text(formattedTime)
                .font(.system(size: 56, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timeColor)
            
            if selectedPenalty != .none {
                Text("Original: \(formatTimeValue(solve.time))")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(themeManager.colors.light.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Scramble Section
    
    @State private var showing3DPreview = false
    
    // MARK: - Scramble Section
    
    private var scrambleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Scramble", systemImage: "cube")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.colors.light.opacity(0.5))
                
                Spacer()
                
                // Show Preview Button
                Button(action: {
                    if let state = getCubeState() {
                        FloatingPreviewManager.shared.toggle(with: state)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Preview")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(themeManager.colors.light.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(themeManager.colors.light.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
            
            Text(solve.scramble ?? "")
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(themeManager.colors.light.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(themeManager.colors.light.opacity(0.05))
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    showing3DPreview = true
                }
        }
        .sheet(isPresented: $showing3DPreview) {
            if let state = getCubeState() {
                NavigationStack {
                    ZStack {
                        themeManager.colors.darkest.ignoresSafeArea()
                        Cube3DView(state: state)
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
        }
        .onDisappear {
            FloatingPreviewManager.shared.hide()
        }
    }
    
    private func getCubeState() -> CubeState? {
        guard let scramble = solve.scramble,
              let typeString = solve.cubeType,
              let type = CubeType(rawValue: typeString) else { return nil }
        
        var state = CubeState(type: type)
        state.apply(moves: scramble)
        return state
    }
    
    // MARK: - Penalty Section
    
    private var penaltySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Penalty", systemImage: "exclamationmark.triangle")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(themeManager.colors.light.opacity(0.5))
            
            HStack(spacing: 10) {
                ForEach(SolvePenalty.allCases, id: \.self) { penalty in
                    PenaltyChip(
                        title: penalty.displayName,
                        isSelected: selectedPenalty == penalty,
                        color: colorForPenalty(penalty)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPenalty = penalty
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Flag Section
    
    private var flagSection: some View {
        HStack {
            Label("Flag this solve", systemImage: isFlagged ? "flag.fill" : "flag")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(isFlagged ? .yellow : themeManager.colors.light.opacity(0.7))
            
            Spacer()
            
            Toggle("", isOn: $isFlagged)
                .tint(.yellow)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(themeManager.colors.light.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(isFlagged ? .yellow.opacity(0.3) : .clear, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Comment Section
    
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Comment", systemImage: "text.bubble")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.colors.light.opacity(0.5))
                
                Spacer()
                
                Text("\(comment.count)/\(maxCommentLength)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(comment.count >= maxCommentLength ? .orange : themeManager.colors.light.opacity(0.3))
            }
            
            TextField("Add a note...", text: $comment, axis: .vertical)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(themeManager.colors.light)
                .lineLimit(3...5)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.05))
                )
                .onChange(of: comment) { _, newValue in
                    if newValue.count > maxCommentLength {
                        comment = String(newValue.prefix(maxCommentLength))
                    }
                }
        }
    }
    
    // MARK: - Metadata Section
    
    private var metadataSection: some View {
        VStack(spacing: 12) {
            MetadataRow(icon: "cube", label: "Cube Type", value: solve.cubeType ?? "3x3")
            
            if let date = solve.date {
                MetadataRow(icon: "calendar", label: "Date", value: formattedDate(date))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(themeManager.colors.light.opacity(0.03))
        )
    }
    
    // MARK: - Helpers
    
    private var formattedTime: String {
        switch selectedPenalty {
        case .dnf:
            return "DNF"
        case .plusTwo:
            return formatTimeValue(solve.time + 2.0) + "+"
        case .none:
            return formatTimeValue(solve.time)
        }
    }
    
    private var timeColor: Color {
        switch selectedPenalty {
        case .dnf:
            return .red.opacity(0.8)
        case .plusTwo:
            return .orange
        case .none:
            return themeManager.colors.light
        }
    }
    
    private func formatTimeValue(_ time: TimeInterval) -> String {
        if time < 60 {
            return String(format: "%.2f", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = time.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%05.2f", minutes, seconds)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func colorForPenalty(_ penalty: SolvePenalty) -> Color {
        switch penalty {
        case .none: return .green
        case .plusTwo: return .orange
        case .dnf: return .red
        }
    }
    
    private func saveChanges() {
        solve.penaltyType = selectedPenalty
        solve.isFlagged = isFlagged
        solve.setComment(comment.isEmpty ? nil : comment)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving solve: \(error)")
        }
    }
}

// MARK: - Penalty Chip

struct PenaltyChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? color : color.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Metadata Row

struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(themeManager.colors.light.opacity(0.5))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(themeManager.colors.light.opacity(0.8))
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let solve = SolveEntity(context: context)
    solve.id = UUID()
    solve.time = 12.45
    solve.scramble = "R U R' U' R' F R2 U' R' U' R U R' F'"
    solve.cubeType = "3x3"
    solve.date = Date()
    solve.penalty = "OK"
    solve.isFlagged = false
    
    return SolveDetailSheet(solve: solve)
        .environment(\.managedObjectContext, context)
}

