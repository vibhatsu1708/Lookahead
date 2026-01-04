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
    
    var body: some View {
        Text(time)
            .font(.system(size: 88, weight: .light, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(timeColor)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.1), value: time)
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
            TimerDisplayView(time: "8.23", state: .stopped)
        }
    }
}

