//
//  StatsView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI
import Charts
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var sessionManager: SessionManager
    
    @State private var selectedCubeFilter: CubeType? = nil
    @State private var selectedSolve: SolveEntity? = nil
    
    private var currentSessionSolves: [SolveEntity] {
        sessionManager.currentSession?.solvesArray ?? []
    }
    
    private var filteredSolves: [SolveEntity] {
        if let filter = selectedCubeFilter {
            return currentSessionSolves.filter { $0.cubeType == filter.rawValue }
        }
        return currentSessionSolves
    }
    
    private var validSolves: [SolveEntity] {
        filteredSolves.filter { $0.penaltyType != .dnf }
    }
    
    private var chronologicalSolves: [SolveEntity] {
        validSolves.reversed()
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
                
                // Content
                if filteredSolves.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Stats summary
                            statsSummary
                            
                            // Line chart
                            lineChart
                                .padding(.horizontal, 24)
                            
                            // Additional stats
                            additionalStats
                                .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 100)
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
                Text("Stats")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("\(currentSessionSolves.count) solves")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
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
    
    // MARK: - Line Chart
    
    private var lineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Solve Times Trend")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            Chart {
                ForEach(Array(chronologicalSolves.enumerated()), id: \.element.id) { index, solve in
                    LineMark(
                        x: .value("Solve", index + 1),
                        y: .value("Time", solve.effectiveTime ?? 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.2, green: 0.9, blue: 0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Solve", index + 1),
                        y: .value("Time", solve.effectiveTime ?? 0)
                    )
                    .foregroundStyle(solve.penaltyType == .plusTwo ? Color.orange : Color(red: 0.4, green: 0.6, blue: 1.0))
                    .symbolSize(60)
                }
                
                // Add average line
                if let avg = averageTime {
                    RuleMark(y: .value("Average", avg))
                        .foregroundStyle(.white.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Avg: \(formatTime(avg))")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.1))
                                )
                        }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let location = value.location
                                    if let (index, _) = proxy.value(at: location, as: (Int, Double).self) {
                                        let chartData = chronologicalSolves
                                        if index >= 1 && index <= chartData.count {
                                            selectedSolve = chartData[index - 1]
                                        }
                                    }
                                }
                        )
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.1))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.1))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Additional Stats
    
    private var additionalStats: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                AdditionalStatCard(
                    title: "Ao12",
                    value: formatTime(ao12),
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                AdditionalStatCard(
                    title: "Worst",
                    value: formatTime(worstTime),
                    icon: "arrow.down.circle"
                )
            }
            
            HStack(spacing: 12) {
                AdditionalStatCard(
                    title: "Median",
                    value: formatTime(medianTime),
                    icon: "chart.bar.fill"
                )
                
                AdditionalStatCard(
                    title: "Std Dev",
                    value: formatStdDev(standardDeviation),
                    icon: "waveform.path.ecg"
                )
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.2))
            
            Text("No stats yet")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
            
            Text("Complete solves to see statistics")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.3))
            
            Spacer()
        }
    }
    
    // MARK: - Calculations
    
    private var bestTime: TimeInterval? {
        validSolves.compactMap { $0.effectiveTime }.min()
    }
    
    private var worstTime: TimeInterval? {
        validSolves.compactMap { $0.effectiveTime }.max()
    }
    
    private var averageTime: TimeInterval? {
        guard !validSolves.isEmpty else { return nil }
        let total = validSolves.compactMap { $0.effectiveTime }.reduce(0, +)
        return total / Double(validSolves.count)
    }
    
    private var medianTime: TimeInterval? {
        let times = validSolves.compactMap { $0.effectiveTime }.sorted()
        guard !times.isEmpty else { return nil }
        let count = times.count
        if count % 2 == 0 {
            return (times[count / 2 - 1] + times[count / 2]) / 2.0
        } else {
            return times[count / 2]
        }
    }
    
    private var standardDeviation: Double? {
        guard let avg = averageTime, validSolves.count > 1 else { return nil }
        let times = validSolves.compactMap { $0.effectiveTime }
        let variance = times.reduce(0) { $0 + pow($1 - avg, 2) } / Double(times.count - 1)
        return sqrt(variance)
    }
    
    private var ao5: TimeInterval? {
        // Calculations handled by StatsSummaryView
        return nil // Placeholder or just remove if unused locally
    }
    
    private var ao12: TimeInterval? {
        let validSolvesForAo12 = Array(filteredSolves.prefix(12))
        guard validSolvesForAo12.count >= 12 else { return nil }
        
        if validSolvesForAo12.contains(where: { $0.penaltyType == .dnf }) {
            return nil
        }
        
        let times = validSolvesForAo12.compactMap { $0.effectiveTime }.sorted()
        guard times.count >= 12 else { return nil }
        let middleTen = Array(times.dropFirst().dropLast())
        return middleTen.reduce(0, +) / 10.0
    }
    
    private func formatTime(_ time: TimeInterval?) -> String {
        guard let time = time else { return "-" }
        if time < 60 {
            return String(format: "%.2f", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = time.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%05.2f", minutes, seconds)
        }
    }
    
    private func formatStdDev(_ value: Double?) -> String {
        guard let value = value else { return "-" }
        return String(format: "±%.2f", value)
    }
}

// MARK: - Additional Stat Card

struct AdditionalStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    StatsView(sessionManager: SessionManager(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
