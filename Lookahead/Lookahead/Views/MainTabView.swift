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
        case settings
    }
    
    init() {
        // Initialize with a temporary context, will be replaced in onAppear
        let context = PersistenceController.shared.container.viewContext
        _sessionManager = StateObject(wrappedValue: SessionManager(context: context))
        
        // Hide default tab bar
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            TabView(selection: $selectedTab) {
                TimerView(sessionManager: sessionManager)
                    .tag(Tab.timer)
                
                HistoryView(sessionManager: sessionManager)
                    .tag(Tab.history)
                
                StatsView(sessionManager: sessionManager)
                    .tag(Tab.stats)
                
                SettingsView()
                    .tag(Tab.settings)
            }
            .safeAreaInset(edge: .bottom) {
                // Add spacer to prevent content being hidden behind the floating bar
                Color.clear.frame(height: 80)
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 12)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    @Namespace private var animation
    @ObservedObject var themeManager = ThemeManager.shared
    
    // Tab definitions for iteration
    private let tabs: [(MainTabView.Tab, String, String)] = [
        (.timer, "Timer", "timer"),
        (.history, "History", "clock.arrow.circlepath"),
        (.stats, "Stats", "chart.xyaxis.line"),
        (.settings, "Settings", "gearshape")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.0) { tab, label, icon in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .symbolVariant(selectedTab == tab ? .fill : .none)
                            
                        // Bouncing Dot
                        if selectedTab == tab {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 4, height: 4)
                                .matchedGeometryEffect(id: "ActiveDot", in: animation)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .foregroundStyle(selectedTab == tab ? themeManager.colors.light : themeManager.colors.light.opacity(0.5))
            }
        }
        .background(
            ZStack {
                // Blur background
                if #available(iOS 15.0, *) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                } else {
                     themeManager.colors.dark.opacity(0.9)
                }
                
                // Border/Glow overlay
                Capsule()
                    .strokeBorder(themeManager.colors.light.opacity(0.1), lineWidth: 1)
            }
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
