//
//  ThemeManager.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case `default`
    case oceanDepth
    case silentStorm
    case desertSand
    case forestMoss
    case sakuraBloom
    case jungleLeaf
    case crimsonRose
    case electricViolet
    case peachyGlow
    case lushHarmony
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .default: return "Default"
        case .oceanDepth: return "Ocean Depth"
        case .silentStorm: return "Silent Storm"
        case .desertSand: return "Desert Sand"
        case .forestMoss: return "Forest Moss"
        case .sakuraBloom: return "Sakura Bloom"
        case .jungleLeaf: return "Jungle Leaf"
        case .crimsonRose: return "Crimson Rose"
        case .electricViolet: return "Electric Violet"
        case .peachyGlow: return "Peachy Glow"
        case .lushHarmony: return "Lush Harmony"
        }
    }
    
    var colors: ThemePalette {
        switch self {
        case .default:
            return ThemePalette(
                darkest: Color(hex: "0F0F14"),
                dark: Color(hex: "1A1426"),
                medium: Color(hex: "adb5bd"),
                light: Color(hex: "FFFFFF"), // White for standard text
                isDefault: true
            )
        case .oceanDepth:
            return ThemePalette(
                darkest: Color(hex: "023e8a"),
                dark: Color(hex: "0077b6"),
                medium: Color(hex: "00b4d8"),
                light: Color(hex: "caf0f8")
            )
        case .silentStorm:
            return ThemePalette(
                darkest: Color(hex: "0d1b2a"),
                dark: Color(hex: "1b263b"),
                medium: Color(hex: "415a77"),
                light: Color(hex: "e0e1dd")
            )
        case .desertSand:
            return ThemePalette(
                darkest: Color(hex: "582f0e"),
                dark: Color(hex: "936639"),
                medium: Color(hex: "a68a64"),
                light: Color(hex: "b6ad90")
            )
        case .forestMoss:
            return ThemePalette(
                darkest: Color(hex: "333d29"),
                dark: Color(hex: "656d4a"),
                medium: Color(hex: "a4ac86"),
                light: Color(hex: "c2c5aa")
            )
        case .sakuraBloom:
            return ThemePalette(
                darkest: Color(hex: "fb6f92"),
                dark: Color(hex: "ff8fab"),
                medium: Color(hex: "ffb3c6"),
                light: Color(hex: "ffe5ec")
            )
        case .jungleLeaf:
            return ThemePalette(
                darkest: Color(hex: "132a13"),
                dark: Color(hex: "31572c"),
                medium: Color(hex: "4f772d"),
                light: Color(hex: "ecf39e")
            )
        case .crimsonRose:
            return ThemePalette(
                darkest: Color(hex: "590d22"),
                dark: Color(hex: "a4133c"),
                medium: Color(hex: "ff4d6d"),
                light: Color(hex: "ffccd5")
            )
        case .electricViolet:
            return ThemePalette(
                darkest: Color(hex: "10002b"),
                dark: Color(hex: "3c096c"),
                medium: Color(hex: "7b2cbf"),
                light: Color(hex: "e0aaff")
            )
        case .peachyGlow:
            return ThemePalette(
                darkest: Color(hex: "472d30"),
                dark: Color(hex: "723d46"),
                medium: Color(hex: "e26d5c"),
                light: Color(hex: "ffe1a8")
            )
        case .lushHarmony:
            return ThemePalette(
                darkest: Color(hex: "054a29"),
                dark: Color(hex: "2a9134"),
                medium: Color(hex: "3fa34d"),
                light: Color(hex: "5bba6f")
            )
        }
    }
}

struct ThemePalette {
    let darkest: Color
    let dark: Color
    let medium: Color
    let light: Color
    var isDefault: Bool = false
    
    // Helper to get a gradient background
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [darkest, dark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Helper for complex background
    @ViewBuilder
    var complexGradient: some View {
        if isDefault {
            ZStack {
                darkest.ignoresSafeArea()
                
                LinearGradient(
                    colors: [
                        dark.opacity(0.6),
                        .clear,
                        medium.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        } else {
            darkest.ignoresSafeArea()
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = AppTheme.default.rawValue
    
    @Published var currentTheme: AppTheme = .default
    
    private init() {
        // Initialize from AppStorage
        if let theme = AppTheme(rawValue: selectedThemeRawValue) {
            currentTheme = theme
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        selectedThemeRawValue = theme.rawValue
        currentTheme = theme
    }
    
    // Convenience accessors
    var colors: ThemePalette {
        currentTheme.colors
    }
}

// Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
