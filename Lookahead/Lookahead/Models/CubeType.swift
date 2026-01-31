//
//  CubeType.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation

enum CubeType: String, CaseIterable, Identifiable {
    case twoByTwo = "2x2"
    case threeByThree = "3x3"
    case fourByFour = "4x4"
    case fiveByFive = "5x5"
    case sixBySix = "6x6"
    case sevenBySeven = "7x7"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .twoByTwo: return "2×2"
        case .threeByThree: return "3×3"
        case .fourByFour: return "4×4"
        case .fiveByFive: return "5×5"
        case .sixBySix: return "6×6"
        case .sevenBySeven: return "7×7"
        }
    }
    
    var scrambleLength: Int {
        switch self {
        case .twoByTwo: return 9
        case .threeByThree: return 20
        case .fourByFour: return 44
        case .fiveByFive: return 60
        case .sixBySix: return 80
        case .sevenBySeven: return 100
        }
    }
    
    var icon: String {
        "cube"
    }
}

