//
//  AlgorithmTrainerMainView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct AlgorithmTrainerMainView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var selectedCase: AlgorithmCase?
    
    var body: some View {
        PageContainer {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Algorithm Trainer")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(themeManager.colors.light)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 12)
                
                // Content
                List {
                    ForEach(AlgorithmCategory.allCases) { category in
                        Section(header: Text("\(category.fullName) (\(AlgorithmData.getTotalCount(for: category)))").font(.system(size: 20, weight: .bold, design: .rounded))) {
                            let sections = AlgorithmData.getSections(for: category)
                            
                            if sections.isEmpty {
                                Text("Coming Soon")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .listRowBackground(themeManager.colors.dark.opacity(0.5))
                            } else {
                                ForEach(sections) { section in
                                    DisclosureGroup {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 12) {
                                                ForEach(section.cases) { algoCase in
                                                    Button {
                                                        selectedCase = algoCase
                                                    } label: {
                                                        AlgorithmCardView(algorithmCase: algoCase, category: category)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 20) // Add manual padding to match design, since list insets are removed
                                        }
                                        .listRowInsets(EdgeInsets())

                                    } label: {
                                        Text("\(section.title) (\(section.cases.count))")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                    .listRowBackground(themeManager.colors.dark.opacity(0.5))
                                    .tint(themeManager.colors.light)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .padding(.bottom, 60)
            }
        }
        .sheet(item: $selectedCase) { algoCase in
            AlgorithmDetailSheet(algorithmCase: algoCase)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    AlgorithmTrainerMainView()
}
