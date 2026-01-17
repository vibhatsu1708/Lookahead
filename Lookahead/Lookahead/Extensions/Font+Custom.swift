//
//  Font+Custom.swift
//  Lookahead
//
//  Created by Antigravity on 05/01/26.
//

import SwiftUI

extension Font {
    enum CustomFont: String {
        case regular = "Raleway-Regular"
        case bold = "Raleway-Bold"
        case semiBold = "Raleway-SemiBold"
        case light = "Raleway-Light"
        case black = "Raleway-Black"
        case extraBold = "Raleway-ExtraBold"
        case medium = "Raleway-Medium"
        case thin = "Raleway-Thin"
        
        var name: String {
            return self.rawValue
        }
    }
    
    static func custom(_ font: CustomFont, size: CGFloat) -> Font {
        return .custom(font.name, size: size)
    }
    
    static func custom(_ font: CustomFont, fixedSize: CGFloat) -> Font {
        return .custom(font.name, fixedSize: fixedSize)
    }
    
    static func custom(_ font: CustomFont, size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        return .custom(font.name, size: size, relativeTo: textStyle)
    }
}
