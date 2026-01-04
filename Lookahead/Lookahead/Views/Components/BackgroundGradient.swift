//
//  BackgroundGradient.swift
//  Lookahead
//
//  Created by Vedant Mistry on 05/01/26.
//

import SwiftUI

struct BackgroundGradient: View {
    var colors: [Color] = [
        Color(red: 0.1, green: 0.08, blue: 0.15).opacity(0.6),
        Color.clear,
        Color(red: 0.08, green: 0.12, blue: 0.15).opacity(0.4)
    ]
    var startPoint: UnitPoint = .topLeading
    var endPoint: UnitPoint = .bottomTrailing
    
    init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.06, blue: 0.08)
            .ignoresSafeArea()
        BackgroundGradient(colors: [
            Color(red: 0.1, green: 0.08, blue: 0.15).opacity(0.6),
            Color.clear,
            Color(red: 0.08, green: 0.12, blue: 0.15).opacity(0.4)
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
