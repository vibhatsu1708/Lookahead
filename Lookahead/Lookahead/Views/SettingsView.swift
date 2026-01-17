//
//  SettingsView.swift
//  Lookahead
//
//  Created by Antigravity on 05/01/26.
//

import SwiftUI


struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    
    @AppStorage("hideTimer") private var hideTimer = false
    @AppStorage("inspectionEnabled") private var inspectionEnabled = false
    

    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.06, green: 0.06, blue: 0.08)
                        .ignoresSafeArea()
                    
                    BackgroundGradient(colors: [
                        Color(red: 0.1, green: 0.08, blue: 0.15).opacity(0.6),
                        Color.clear,
                        Color(red: 0.08, green: 0.12, blue: 0.15).opacity(0.4)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    
                    List {

                        
                        Section {
                            Toggle(isOn: $hideTimer) {
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .foregroundStyle(.purple)
                                    Text("Hide Timer While Solving")
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            Toggle(isOn: $inspectionEnabled) {
                                HStack {
                                    Image(systemName: "stopwatch.fill")
                                        .foregroundStyle(.orange)
                                    Text("Inspection Time (15s)")
                                        .foregroundStyle(.white)
                                }
                            }
                        } header: {
                            Text("Timer")
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                        
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Settings")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
