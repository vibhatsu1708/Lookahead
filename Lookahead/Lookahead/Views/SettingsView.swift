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
            PageContainer {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Theme Picker Section
                        ThemeCarousel()
                            .padding(.vertical, 10)
                        
                        // Timer Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Timer")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(themeManager.colors.light.opacity(0.8))
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 12) {
                                Toggle(isOn: $hideTimer) {
                                    HStack {
                                        Image(systemName: "eye.slash.fill")
                                            .foregroundStyle(themeManager.colors.medium)
                                            .frame(width: 24)
                                        Text("Hide Timer While Solving")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(themeManager.colors.light)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                                        )
                                )
                                
                                Toggle(isOn: $inspectionEnabled) {
                                    HStack {
                                        Image(systemName: "stopwatch.fill")
                                            .foregroundStyle(themeManager.colors.medium)
                                            .frame(width: 24)
                                        Text("Inspection Time (15s)")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(themeManager.colors.light)
                                    }
                                }
                                .padding(16)
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
                    }
                    .padding(24)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
            }
        }
        .preferredColorScheme(.dark)
    }
}
