//
//  TimerDisplayView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct TimerDisplayView: View {
    let time: String
    let state: TimerState
    var shimmerDirection: ShimmerDirection = .leftToRight
    
    private var isTimerActive: Bool {
        state == .running
    }
    
    private var timeColor: Color {
        switch state {
        case .idle:
            return .white.opacity(0.3)
        case .ready:
            return Color(red: 0.2, green: 0.9, blue: 0.4) // Bright green
        case .running:
            return .white
        case .stopped:
            return Color(red: 1.0, green: 0.85, blue: 0.3) // Golden yellow
        }
    }
    
    private var shimmerBaseColor: Color {
        .white.opacity(0.12)
    }
    
    private var shimmerHighlightColor: Color {
        .white.opacity(0.35)
    }
    
    // Split time into whole and decimal digits
    private var timeParts: (whole: String, decimalDigit1: String, decimalDigit2: String) {
        let components = time.split(separator: ".", maxSplits: 1)
        if components.count == 2 {
            let decimalPart = String(components[1])
            let digit1 = decimalPart.count > 0 ? String(decimalPart.prefix(1)) : "0"
            let digit2 = decimalPart.count > 1 ? String(decimalPart.dropFirst().prefix(1)) : "0"
            return (String(components[0]), digit1, digit2)
        }
        return (time, "0", "0")
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Whole seconds (with numeric transition)
            Text(timeParts.whole)
                .font(.system(size: 88, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timeColor)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: timeParts.whole)
            
            // Decimal point
            Text(".")
                .font(.system(size: 88, weight: .light, design: .rounded))
                .foregroundStyle(timeColor)
            
            // Decimal digits with shimmer rectangles (only when timer is active)
            if isTimerActive {
                HStack(spacing: 4) {
                    // First decimal digit
                    Text(timeParts.decimalDigit1)
                        .font(.system(size: 88, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(timeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(
                            ShimmerView(
                                direction: shimmerDirection,
                                isActive: true,
                                baseColor: shimmerBaseColor,
                                shimmerColor: shimmerHighlightColor,
                                duration: 1.2,
                                cornerRadius: 12
                            )
                        )
                    
                    // Second decimal digit
                    Text(timeParts.decimalDigit2)
                        .font(.system(size: 88, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(timeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(
                            ShimmerView(
                                direction: shimmerDirection,
                                isActive: true,
                                baseColor: shimmerBaseColor,
                                shimmerColor: shimmerHighlightColor,
                                duration: 1.2,
                                cornerRadius: 12
                            )
                        )
                }
            } else {
                // Plain decimal digits without rectangles
                Text(timeParts.decimalDigit1 + timeParts.decimalDigit2)
                    .font(.system(size: 88, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(timeColor)
            }
        }
        .shadow(color: timeColor.opacity(0.3), radius: 20, x: 0, y: 0)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 40) {
            TimerDisplayView(time: "0.00", state: .idle)
            TimerDisplayView(time: "0.00", state: .ready)
            TimerDisplayView(time: "12.45", state: .running)
            TimerDisplayView(time: "1:08.23", state: .stopped, shimmerDirection: .rightToLeft)
        }
    }
}
