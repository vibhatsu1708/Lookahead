//
//  StatsSummaryView.swift
//  Lookahead
//
//  Created by Antigravity on 05/01/26.
//

import SwiftUI

struct StatsSummaryView: View {
    let solves: [SolveEntity]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Best",
                    value: formatTime(bestTime),
                    color: Color(red: 0.2, green: 0.9, blue: 0.4)
                )
                
                StatCard(
                    title: "Avg",
                    value: formatTime(averageTime),
                    color: Color(red: 0.4, green: 0.6, blue: 1.0)
                )
                
                StatCard(
                    title: "Ao5",
                    value: formatTime(calculateAverageOf(5)),
                    color: Color(red: 1.0, green: 0.6, blue: 0.3)
                )
                
                StatCard(
                    title: "Ao12",
                    value: formatTime(calculateAverageOf(12)),
                    color: Color(red: 1.0, green: 0.5, blue: 0.5)
                )
                
                StatCard(
                    title: "Ao20",
                    value: formatTime(calculateAverageOf(20)),
                    color: Color(red: 0.8, green: 0.6, blue: 1.0)
                )
                
                StatCard(
                    title: "Ao50",
                    value: formatTime(calculateAverageOf(50)),
                    color: Color(red: 0.5, green: 0.8, blue: 1.0)
                )
                
                StatCard(
                    title: "Ao100",
                    value: formatTime(calculateAverageOf(100)),
                    color: Color(red: 0.4, green: 1.0, blue: 0.8)
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Calculations
    
    private var bestTime: TimeInterval? {
        solves
            .filter { $0.penaltyType != .dnf }
            .compactMap { $0.effectiveTime }
            .min()
    }
    
    private var averageTime: TimeInterval? {
        let validSolves = solves.filter { $0.penaltyType != .dnf }
        guard !validSolves.isEmpty else { return nil }
        let total = validSolves.compactMap { $0.effectiveTime }.reduce(0, +)
        return total / Double(validSolves.count)
    }
    
    private func calculateAverageOf(_ count: Int) -> TimeInterval? {
        // We take the N most recent solves
        let relevantSolves = Array(solves.prefix(count))
        guard relevantSolves.count >= count else { return nil }
        
        // Count DNFs
        let dnfCount = relevantSolves.filter { $0.penaltyType == .dnf }.count
        
        // For AoN, usually only 1 DNF is allowed for Ao5/Ao12. 
        // For larger sets, it might be more, but standard WCA rule is 1 DNF = DNF for Ao5/Ao12.
        // For larger ones like 100, we'll keep it simple: any DNF = DNF for now, or follow a rule?
        // Let's stick to: if there's any DNF in the sample, the average is DNF.
        if dnfCount > 0 {
            return nil
        }
        
        let times = relevantSolves.compactMap { $0.effectiveTime }.sorted()
        
        // WCA Rule: Drop best and worst
        let middleTimes = Array(times.dropFirst().dropLast())
        return middleTimes.reduce(0, +) / Double(middleTimes.count)
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
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .frame(width: 100)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
