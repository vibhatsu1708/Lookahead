//
//  PageContainer.swift
//  Lookahead
//
//  Created by Vedant Mistry on 17/01/26.
//

import SwiftUI

struct PageContainer<Content: View>: View {
    @ObservedObject var themeManager = ThemeManager.shared
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                themeManager.colors.complexGradient
                
                // Content
                content
            }
        }
    }
}
