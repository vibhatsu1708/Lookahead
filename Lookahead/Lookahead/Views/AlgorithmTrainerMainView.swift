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
    
    // Track expanded states for sections
    @State private var expandedSections: Set<UUID> = []
    
    // Grid layout for 2 columns
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
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
                .padding(.bottom, 20)
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        
                        // F2L Section
                        if let f2lSections = AlgorithmData.getSections(for: .f2l) as? [AlgorithmSection], !f2lSections.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                // Special handling for "Basic Inserts" (First Section) - Horizontal Carousel
                                if let basicInserts = f2lSections.first(where: { $0.title == "Basic Inserts" }) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(basicInserts.cases) { algoCase in
                                                Button {
                                                    selectedCase = algoCase
                                                } label: {
                                                    // Fixed width for carousel items
                                                    AlgorithmCardView(algorithmCase: algoCase, category: .f2l)
                                                        .frame(width: 170)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                                
                                // Remaining F2L Sections - Collapsible Lists
                                let otherF2L = f2lSections.filter { $0.title != "Basic Inserts" }
                                ForEach(otherF2L) { section in
                                    CollapsibleSectionView(
                                        title: "\(section.title) (\(section.cases.count))",
                                        isExpanded: Binding(
                                            get: { expandedSections.contains(section.id) },
                                            set: { isExpanded in
                                                if isExpanded {
                                                    expandedSections.insert(section.id)
                                                } else {
                                                    expandedSections.remove(section.id)
                                                }
                                            }
                                        )
                                    ) {
                                        LazyVGrid(columns: columns, spacing: 12) {
                                            ForEach(section.cases) { algoCase in
                                                Button {
                                                    selectedCase = algoCase
                                                } label: {
                                                    AlgorithmCardView(algorithmCase: algoCase, category: .f2l)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                        
                        // OLL Section
                        renderCategorySection(category: .oll)
                        
                        // PLL Section
                        renderCategorySection(category: .pll)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(item: $selectedCase) { algoCase in
            AlgorithmDetailSheet(algorithmCase: algoCase)
                .presentationDetents([.medium, .large])
        }
    }
    
    @ViewBuilder
    private func renderCategorySection(category: AlgorithmCategory) -> some View {
        let sections = AlgorithmData.getSections(for: category)
        if !sections.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                // Category Header
                Text("\(category.fullName) (\(AlgorithmData.getTotalCount(for: category)))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(themeManager.colors.light.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .textCase(.uppercase)
                
                ForEach(sections) { section in
                    CollapsibleSectionView(
                        title: "\(section.title) (\(section.cases.count))",
                        isExpanded: Binding(
                            get: { expandedSections.contains(section.id) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedSections.insert(section.id)
                                } else {
                                    expandedSections.remove(section.id)
                                }
                            }
                        )
                    ) {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(section.cases) { algoCase in
                                Button {
                                    selectedCase = algoCase
                                } label: {
                                    AlgorithmCardView(algorithmCase: algoCase, category: category)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

struct CollapsibleSectionView<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    let content: () -> Content
    
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(themeManager.colors.light)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(themeManager.colors.mainAccent)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(themeManager.colors.dark.opacity(0.3))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95, anchor: .top)))
            }
            
            Divider()
                .background(themeManager.colors.light.opacity(0.05))
                .padding(.leading, 24)
        }
    }
}

#Preview {
    AlgorithmTrainerMainView()
}
