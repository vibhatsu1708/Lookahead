//
//  MainTabView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var sessionManager: SessionManager
    @State private var selectedTab: Tab = .timer
    
    enum Tab {
        case timer
        case history
        case stats
    }
    
    init() {
        // Initialize with a temporary context, will be replaced in onAppear
        let context = PersistenceController.shared.container.viewContext
        _sessionManager = StateObject(wrappedValue: SessionManager(context: context))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView(sessionManager: sessionManager)
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(Tab.timer)
            
            HistoryView(sessionManager: sessionManager)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)
            
            StatsView(sessionManager: sessionManager)
                .tabItem {
                    Label("Stats", systemImage: "chart.xyaxis.line")
                }
                .tag(Tab.stats)
        }
        .tint(.white)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
