//
//  GlobalFontModifier.swift
//  Lookahead
//
//  Created by Antigravity on 05/01/26.
//

import SwiftUI

struct GlobalFontModifier: ViewModifier {
    var size: CGFloat = 16
    var font: Font.CustomFont = .regular
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font, size: size))
    }
}

extension View {
    func useGlobalFont(font: Font.CustomFont = .regular, size: CGFloat = 16) -> some View {
        self.modifier(GlobalFontModifier(size: size, font: font))
    }
}
