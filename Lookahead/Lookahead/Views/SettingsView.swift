//
//  SettingsView.swift
//  Lookahead
//
//  Created by Antigravity on 05/01/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var themeManager = ThemeManager.shared
    
    @AppStorage("hideTimer") private var hideTimer = false
    @AppStorage("inspectionEnabled") private var inspectionEnabled = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Dynamic Theme Background
                    themeManager.colors.complexGradient
                    
                    List {
                        // Theme Picker Section
                        Section {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 20)], spacing: 20) {
                                ForEach(AppTheme.allCases) { theme in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            themeManager.setTheme(theme)
                                        }
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(theme.colors.backgroundGradient)
                                                .frame(width: 44, height: 44)
                                                .shadow(color: .black.opacity(0.3), radius: 3)
                                            
                                            // Selection Ring
                                            if themeManager.currentTheme == theme {
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 2)
                                                    .frame(width: 50, height: 50)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                        } header: {
                            Text("Theme")
                                .foregroundStyle(themeManager.colors.light.opacity(0.8))
                        }
                        .listRowBackground(Color.clear) // Transparent row for grid
                        
                        // Timer Settings
                        Section {
                            Toggle(isOn: $hideTimer) {
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .foregroundStyle(themeManager.colors.medium)
                                    Text("Hide Timer While Solving")
                                        .foregroundStyle(themeManager.colors.light)
                                }
                            }
                            
                            Toggle(isOn: $inspectionEnabled) {
                                HStack {
                                    Image(systemName: "stopwatch.fill")
                                        .foregroundStyle(themeManager.colors.medium)
                                    Text("Inspection Time (15s)")
                                        .foregroundStyle(themeManager.colors.light)
                                }
                            }
                        } header: {
                            Text("Timer")
                                .foregroundStyle(themeManager.colors.light.opacity(0.8))
                        }
                        .listRowBackground(themeManager.colors.darkest.opacity(0.3))
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Settings")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
