//
//  AlgorithmModels.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import Foundation

enum AlgorithmCategory: String, CaseIterable, Identifiable {
    case f2l = "F2L"
    case oll = "OLL"
    case pll = "PLL"
    
    var id: String { rawValue }
    
    var fullName: String {
        switch self {
        case .f2l: return "F2L - First 2 Layers"
        case .oll: return "OLL - Orientation of Last Layer"
        case .pll: return "PLL - Permutation of Last Layer"
        }
    }
}

struct AlgorithmCase: Identifiable, Hashable {
    let id = UUID()
    let name: String
    /// The algorithm to set up the case (so we can show the "before" state)
    let setupMoves: String
    /// The solution algorithm
    let algorithm: String
    
    // Hashable conformance for using in ForEach/Navigation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AlgorithmCase, rhs: AlgorithmCase) -> Bool {
        lhs.id == rhs.id
    }
}

struct AlgorithmSection: Identifiable {
    let id = UUID()
    let title: String
    let cases: [AlgorithmCase]
}

struct AlgorithmData {
    static let f2lSections: [AlgorithmSection] = [
        AlgorithmSection(title: "Basic Inserts", cases: [
            AlgorithmCase(
                name: "Right Insert",
                setupMoves: "(R U R') U'",
                algorithm: "U (R U' R')"
            ),
            AlgorithmCase(
                name: "Left Insert",
                setupMoves: "(R' U R) y",
                algorithm: "y' (R' U' R)"
            )
        ]),
        AlgorithmSection(title: "F2L Case 1", cases: [
            AlgorithmCase(
                name: "Case 1a",
                setupMoves: "(R' U R) y (U' R U R' U)",
                algorithm: "U' (R U' R' U) y' (R' U' R)"
            ),
            AlgorithmCase(
                name: "Case 1b",
                setupMoves: "(R' U R) y (U' R U2 R' U)",
                algorithm: "U' (R U2' R' U) y' (R' U' R)"
            ),
            AlgorithmCase(
                name: "Case 1c",
                setupMoves: "(R' U R) (U R' U' R) U' y",
                algorithm: "y' U (R' U R U') (R' U' R)"
            )
        ]),
        AlgorithmSection(title: "F2L Case 2", cases: [
            AlgorithmCase(
                name: "Case 2a",
                setupMoves: "(R U' R')",
                algorithm: "(R U R')"
            ),
            AlgorithmCase(
                name: "Case 2b",
                setupMoves: "(R U' R') (U' R U' R' U)",
                algorithm: "U' (R U R' U) (R U R')"
            ),
            AlgorithmCase(
                name: "Case 2c",
                setupMoves: "(R U' R') (U' R U R' U)",
                algorithm: "U' (R U' R' U) (R U R')"
            ),
            AlgorithmCase(
                name: "Case 2d",
                setupMoves: "(R U R') U2 (R U' R' U)",
                algorithm: "(U' R U R') U2 (R U' R')"
            ),
            AlgorithmCase(
                name: "Case 2e",
                setupMoves: "(R U R') U2 (R U2 R') U",
                algorithm: "U' (R U2' R') U2 (R U' R')"
            )
        ]),
        AlgorithmSection(title: "F2L Case 3", cases: [
            AlgorithmCase(
                name: "Case 3a",
                setupMoves: "(R' U' R) U2 (R' U R U') y",
                algorithm: "y' (U R' U' R) U2' (R' U R)"
            ),
            AlgorithmCase(
                name: "Case 3b",
                setupMoves: "(R' U' R) U2 (R' U2' R) U' y",
                algorithm: "y' U (R' U2 R) U2' (R' U R)"
            ),
            AlgorithmCase(
                name: "Case 3c",
                setupMoves: "(R U R') U' (R U2' R') U'",
                algorithm: "U (R U2 R') U (R U' R')"
            ),
            AlgorithmCase(
                name: "Case 3d",
                setupMoves: "(R U R') (U' R U' R') U2",
                algorithm: "U2 (R U R' U) (R U' R')"
            )
        ]),
        AlgorithmSection(title: "Special Cases", cases: [
            AlgorithmCase(
                name: "Incorrectly Connected",
                setupMoves: "(R U' R') y' U2 (R' U' R) y",
                algorithm: "y' (R' U R) U2' y (R U R')"
            ),
            AlgorithmCase(
                name: "Incorrectly Connected (Alternative)",
                setupMoves: "(R U' R') U (R U2' R')",
                algorithm: "(R U2 R') U' (R U R')"
            ),
            AlgorithmCase(
                name: "Corner in Place, Edge in U Face",
                setupMoves: "(R U R') (U' R U R')",
                algorithm: "(R U' R' U) (R U' R')"
            ),
            AlgorithmCase(
                name: "Edge in Place, Corner in U Face",
                setupMoves: "(R' U' R) y (U' R U R')",
                algorithm: "(R U' R' U) y' (R' U R)"
            ),
            AlgorithmCase(
                name: "Edge and Corner in Place (Flipped Edge)",
                setupMoves: "(R U' R') (U R U' R')",
                algorithm: "(R U R' U') (R U R')"
            ),
            AlgorithmCase(
                name: "Edge and Corner in Place (Twisted Corner)",
                setupMoves: "(R U' R') U2 (R U' R') U'",
                algorithm: "U (R U R') U2 (R U R')"
            )
        ])
    ]
    
    static let ollSections: [AlgorithmSection] = [
        AlgorithmSection(title: "All Edges Oriented Correctly", cases: [
            AlgorithmCase(
                name: "OCLL6 (Sune)",
                setupMoves: "R U R' U R U2' R'", // Reverse of R U2 R' U' R U' R'
                algorithm: "R U2 R' U' R U' R'"
            ),
             AlgorithmCase(
                name: "OCLL7 (Anti-Sune)",
                setupMoves: "R U2' R' U' R U' R'", // Reverse of (R U R' U R U2' R')
                algorithm: "R U R' U R U2' R'"
            ),
             AlgorithmCase(
                name: "OCLL1 (H)",
                setupMoves: "(R U R' U') (R' U R U') (R' U2 R)", // Reverse of (R U2 R') (U' R U' R') etc.. wait, let's just inverse carefully or use a known setup
                // Alg: (R U2 R') (U' R U R') (U' R U' R')
                // Inv: (R U R' U) (R' U' R' U) (R U2' R')
                algorithm: "(R U2 R') (U' R U R') (U' R U' R')"
            ),
             AlgorithmCase(
                name: "OCLL2 (Pi)",
                setupMoves: "R' U2 R2 U R2' U R2 U2' R'", // Reverse of R U2' R2' U' R2 U' R2' U2' R
                algorithm: "R U2' R2' U' R2 U' R2' U2' R"
            ),
             AlgorithmCase(
                name: "OCLL4 (U)",
                setupMoves: "(F R' F' r) (U R U' r')", // Reverse of (r U R' U') (r' F R F')
                algorithm: "(r U R' U') (r' F R F')"
            ),
             AlgorithmCase(
                name: "OCLL5 (L)",
                setupMoves: "R' F' r (U R U' r') F y'", // Reverse of y F' (r U R' U') r' F R
                algorithm: "y F' (r U R' U') r' F R"
            ),
             AlgorithmCase(
                name: "OCLL3 (Antisune+)",
                setupMoves: "(R U2' R) D (R' U2' R) D' R2", // Inverse of R2 D (R' U2 R) D' (R' U2 R')
                algorithm: "R2 D (R' U2 R) D' (R' U2 R')"
            )
        ]),
        AlgorithmSection(title: "T-Shapes", cases: [
            AlgorithmCase(
                name: "T1 (T)",
                setupMoves: "(F R' F' R) (U R U' R')", // Reverse of (R U R' U') (R' F R F')
                algorithm: "(R U R' U') (R' F R F')"
            ),
            AlgorithmCase(
                name: "T2 (Anti-T)",
                setupMoves: "F (U R U' R') F'", // Reverse of F (R U R' U') F'
                algorithm: "F (R U R' U') F'"
            )
        ])
    ]
    

    static let pllSections: [AlgorithmSection] = [
        AlgorithmSection(title: "Permutations of Edges Only", cases: [
            AlgorithmCase(
                name: "Ub",
                setupMoves: "(R U' R) U R (U R U' R') U' R2", // Inverse of R2 U (R U R' U') R' U' (R' U R')
                algorithm: "R2 U (R U R' U') R' U' (R' U R')"
            ),
            AlgorithmCase(
                name: "Ua",
                setupMoves: "R2 (U R U R') U' R' (U' R' U R')", // Inverse of (R U' R U) R U (R U' R' U') R2
                algorithm: "(R U' R U) R U (R U' R' U') R2"
            ),
            AlgorithmCase(
                name: "Z",
                setupMoves: "(M U2 M2') (U2 M) (U' M2' U' M2')", // Inverse of (M2' U M2' U) (M' U2) (M2' U2 M')
                algorithm: "(M2' U M2' U) (M' U2) (M2' U2 M')"
            ),
            AlgorithmCase(
                name: "H",
                setupMoves: "(M2' U' M2') U2 (M2' U' M2')", // Inverse of (M2' U M2') U2 (M2' U M2')
                algorithm: "(M2' U M2') U2 (M2' U M2')"
            )
        ]),
        AlgorithmSection(title: "Permutations of Corners Only", cases: [
            AlgorithmCase(
                name: "Aa",
                setupMoves: "x R2 D2 (R U R') D2 (R U' R) x'", // Inverse of x (R' U R') D2 (R U' R') D2 R2 x'
                algorithm: "x (R' U R') D2 (R U' R') D2 R2 x'"
            ),
            AlgorithmCase(
                name: "Ab",
                setupMoves: "x (R' U' R') D2 (R U' R') D2 R2 x'", // Inverse of x R2' D2 (R U R') D2 (R U' R) x'
                algorithm: "x R2' D2 (R U R') D2 (R U' R) x'"
            ),
            AlgorithmCase(
                name: "E",
                setupMoves: "x' (D R U R') (D' R U' R') (D R U' R') (D' R U R') x", // Inverse of x' (R U' R' D) (R U R' D') (R U R' D) (R U' R' D') x
                algorithm: "x' (R U' R' D) (R U R' D') (R U R' D) (R U' R' D') x"
            )
        ])
    ]
    
    static func getSections(for category: AlgorithmCategory) -> [AlgorithmSection] {
        switch category {
        case .f2l: return f2lSections
        case .oll: return ollSections
        case .pll: return pllSections
        }
    }
}
