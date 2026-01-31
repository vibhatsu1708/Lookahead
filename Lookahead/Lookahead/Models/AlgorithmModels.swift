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
        AlgorithmSection(title: "Dot Cases (No Edges Oriented)", cases: [
            AlgorithmCase(
                name: "OLL 1 (Runway)",
                setupMoves: "F R' F' R U2' F R' F' R2' U2' R'",
                algorithm: "(R U2 R') (R' F R F') U2 (R' F R F')"
            ),
            AlgorithmCase(
                name: "OLL 2 (Zamboni)",
                setupMoves: "f U R U' R' f' F U R U' R' F'",
                algorithm: "F (R U R' U') F' f (R U R' U') f'"
            ),
            AlgorithmCase(
                name: "OLL 3 (Anti-Pinwheel)",
                setupMoves: "F U R U' R' F' U f U R U' R' f' y",
                algorithm: "y' f (R U R' U') f' U' F (R U R' U') F'"
            ),
            AlgorithmCase(
                name: "OLL 4 (Pinwheel)",
                setupMoves: "F U R U' R' F' U' f U R U' R' f' y",
                algorithm: "y' f (R U R' U') f' U F (R U R' U') F'"
            ),
            AlgorithmCase(
                name: "OLL 17 (Slash/Diagonal)",
                setupMoves: "F R' F' R U2' F R' F' R U' R U' R'",
                algorithm: "(R U R' U) (R' F R F') U2 (R' F R F')"
            ),
            AlgorithmCase(
                name: "OLL 18 (Crown)",
                setupMoves: "r' U2' R U R' U r2' U2' R' U' R U' r'",
                algorithm: "r U R' U R U2 r2 U' R U' R' U2 r"
            ),
            AlgorithmCase(
                name: "OLL 19 (Bunny)",
                setupMoves: "M U R U R' U' M' R' F R F'",
                algorithm: "r' R U R U R' U' r R2 F R F'"
            ),
            AlgorithmCase(
                name: "OLL 20 (X/Checkers)",
                setupMoves: "r U R' U' M2' U R U' R' U' M'",
                algorithm: "(r U R' U') M2 (U R U' R') U' M'"
            )
        ]),
        AlgorithmSection(title: "Square Shapes", cases: [
            AlgorithmCase(
                name: "OLL 5",
                setupMoves: "r' U' R U' R' U2' r",
                algorithm: "r' U2 (R U R' U) r"
            ),
            AlgorithmCase(
                name: "OLL 6",
                setupMoves: "r U R' U R U2' r'",
                algorithm: "r U2 (R' U' R U') r'"
            )
        ]),
        AlgorithmSection(title: "Lightning Shapes", cases: [
            AlgorithmCase(
                name: "OLL 7",
                setupMoves: "r U2' R' U' R U' r'",
                algorithm: "r (U R' U R) U2 r'"
            ),
            AlgorithmCase(
                name: "OLL 8",
                setupMoves: "r' U2' R U R' U r y2'",
                algorithm: "y2 r' (U' R U' R') U2 r"
            ),
            AlgorithmCase(
                name: "OLL 11",
                setupMoves: "M U' R U2' R' U' R U' R2' r",
                algorithm: "M (R U R' U R U2 R') U M'"
            ),
            AlgorithmCase(
                name: "OLL 12",
                setupMoves: "F U R U' R' F' U' F U R U' R' F'",
                algorithm: "y' M' (R' U' R U' R' U2 R) U' M"
            ),
            AlgorithmCase(
                name: "OLL 39",
                setupMoves: "L F' L' U' L U F U' L'",
                algorithm: "f (R U R' U') f' U (R U R' U')"
            ),
            AlgorithmCase(
                name: "OLL 40",
                setupMoves: "R' F R U R' U' F' U R",
                algorithm: "f' (L' U' L U) f U' (L' U' L U)"
            )
        ]),
        AlgorithmSection(title: "Fish Shapes", cases: [
            AlgorithmCase(
                name: "OLL 9",
                setupMoves: "F U R U' R2' F' R U R U' R' y'",
                algorithm: "y (R U R' U') (R' F R) (R U R' U') F'"
            ),
            AlgorithmCase(
                name: "OLL 10",
                setupMoves: "R U2' R' F R' F' R U' R U' R'",
                algorithm: "(R U R' U) (R' F R F') (R U2 R')"
            ),
            AlgorithmCase(
                name: "OLL 35",
                setupMoves: "R U2 R2' F R F' R U2' R'",
                algorithm: "R U2 R2 F R F' R U2 R'"
            ),
            AlgorithmCase(
                name: "OLL 37",
                setupMoves: "F R U' R' U' R U R' F'",
                algorithm: "F R' F' R U R U' R'"
            )
        ]),
        AlgorithmSection(title: "Knight Move Shapes", cases: [
            AlgorithmCase(
                name: "OLL 13",
                setupMoves: "F' U' F r U' r' U r U r'",
                algorithm: "(r U' r') U' (r U r') (F' U F)"
            ),
            AlgorithmCase(
                name: "OLL 14",
                setupMoves: "F U F' R' F R U' R' F' R",
                algorithm: "R' F (R U R') F' R (F U' F')"
            ),
            AlgorithmCase(
                name: "OLL 15",
                setupMoves: "r' U' r U' R' U R r' U r",
                algorithm: "(r' U' r) (R' U' R U) (r' U r)"
            ),
            AlgorithmCase(
                name: "OLL 16",
                setupMoves: "r U r' U R U' R' r U' r'",
                algorithm: "(r U r') (R U R' U') (r U' r')"
            )
        ]),
        AlgorithmSection(title: "OCLL (All Edges Oriented)", cases: [
            AlgorithmCase(
                name: "OLL 21 (H/Cross)",
                setupMoves: "R U R' U R U' R' U R U2' R' y'",
                algorithm: "(R U R' U) (R U' R' U) (R U2 R')"
            ),
            AlgorithmCase(
                name: "OLL 22 (Pi/Wheel)",
                setupMoves: "R' U2' R2' U R2' U R2' U2' R'",
                algorithm: "R U2 (R2' U') (R2 U') (R2' U') U' R"
            ),
            AlgorithmCase(
                name: "OLL 23 (U/Headlights)",
                setupMoves: "R2 D R' U2 R D' R' U2 R'",
                algorithm: "(R2 D') (R U2 R') (D R U2 R)"
            ),
            AlgorithmCase(
                name: "OLL 24 (T/Chameleon)",
                setupMoves: "r U R' U' r' F R F'",
                algorithm: "(r U R' U') (r' F R F')"
            ),
            AlgorithmCase(
                name: "OLL 25 (L/Bowtie)",
                setupMoves: "R' F' r U R U' r' F y'",
                algorithm: "y (F' r U R') (U' r' F R)"
            ),
            AlgorithmCase(
                name: "OLL 26 (Antisune)",
                setupMoves: "R U R' U R U2' R' y'",
                algorithm: "y R U2 (R' U' R U') R'"
            ),
            AlgorithmCase(
                name: "OLL 27 (Sune)",
                setupMoves: "R U2' R' U' R U' R'",
                algorithm: "(R U R' U) (R U2 R')"
            )
        ]),
        AlgorithmSection(title: "P Shapes", cases: [
            AlgorithmCase(
                name: "OLL 31 (Couch)",
                setupMoves: "R' F R U R' U' F' U R",
                algorithm: "(R' U' F) (U R U' R') F' R"
            ),
            AlgorithmCase(
                name: "OLL 32 (Anti-Couch)",
                setupMoves: "L U F' U' L' U L F L'",
                algorithm: "(L U F') (U' L' U L) F L'"
            ),
            AlgorithmCase(
                name: "OLL 43",
                setupMoves: "R' U' F' U F R",
                algorithm: "(f' L' U' L U f)"
            ),
            AlgorithmCase(
                name: "OLL 44",
                setupMoves: "F U R U' R' F'",
                algorithm: "(f R U R' U' f')"
            )
        ]),
        AlgorithmSection(title: "T Shapes", cases: [
            AlgorithmCase(
                name: "OLL 33",
                setupMoves: "R U R' U' R' F R F'",
                algorithm: "(R U R' U') (R' F R F')"
            ),
            AlgorithmCase(
                name: "OLL 45",
                setupMoves: "F U R U' R' F'",
                algorithm: "F (R U R' U') F'"
            )
        ]),
        AlgorithmSection(title: "C Shapes", cases: [
            AlgorithmCase(
                name: "OLL 34",
                setupMoves: "R U R2' U' R' F R U R U' F'",
                algorithm: "(R U R' U') (B' R' F R F' B)"
            ),
            AlgorithmCase(
                name: "OLL 46",
                setupMoves: "R' U' R' F R F' U R",
                algorithm: "(R' U' R' F R F' U R)"
            )
        ]),
        AlgorithmSection(title: "W Shapes", cases: [
            AlgorithmCase(
                name: "OLL 36",
                setupMoves: "L' U' L U' L' U L U L F' L' F",
                algorithm: "(R' U' R U') (R' U R U) (R B' R' B)"
            ),
            AlgorithmCase(
                name: "OLL 38",
                setupMoves: "R U R' U R U' R' U' R' F R F'",
                algorithm: "(R U R' U) (R U' R' U') (R' F R F')"
            )
        ]),
        AlgorithmSection(title: "Awkward Shapes", cases: [
            AlgorithmCase(
                name: "OLL 29",
                setupMoves: "M F R' F' R U R U' R' U' M'",
                algorithm: "y (R U R') U' (R U' R') (F' U' F) (R U R')"
            ),
            AlgorithmCase(
                name: "OLL 30",
                setupMoves: "F U R U2' R' U R U2' R' U' F' y2'",
                algorithm: "y2 F U (R U2 R') U' (R U2 R') U' F'"
            ),
            AlgorithmCase(
                name: "OLL 41",
                setupMoves: "F U R U' R' F' R U2' R' U' R U' R' y2'",
                algorithm: "y2 (R U R' U) (R U2 R') F (R U R' U') F'"
            ),
            AlgorithmCase(
                name: "OLL 42",
                setupMoves: "M U F R U R' U' F' M'",
                algorithm: "(R' U' R U') (R' U2 R) F (R U R' U') F'"
            )
        ]),
        AlgorithmSection(title: "L Shapes", cases: [
            AlgorithmCase(
                name: "OLL 47",
                setupMoves: "F' U' L' U L U' L' U L F",
                algorithm: "F' (L' U' L U) (L' U' L U) F"
            ),
            AlgorithmCase(
                name: "OLL 48",
                setupMoves: "F U R U' R' U R U' R' F'",
                algorithm: "F (R U R' U') (R U R' U') F'"
            ),
            AlgorithmCase(
                name: "OLL 49",
                setupMoves: "r U' r2' U r2 U r2' U' r",
                algorithm: "r U' r2 U r2 U r2 U' r"
            ),
            AlgorithmCase(
                name: "OLL 50",
                setupMoves: "r' U r2 U' r2' U' r2 U r'",
                algorithm: "r' U r2 U' r2 U' r2 U r'"
            ),
            AlgorithmCase(
                name: "OLL 53",
                setupMoves: "r' U' R U' R' U R U' R' U2 r",
                algorithm: "r' U' R U' R' U R U' R' U2 r"
            ),
            AlgorithmCase(
                name: "OLL 54",
                setupMoves: "r U R' U R U' R' U R U2' r'",
                algorithm: "(r U R' U R U' R' U R U2 r')"
            )
        ]),
        AlgorithmSection(title: "Line Shapes", cases: [
            AlgorithmCase(
                name: "OLL 51",
                setupMoves: "f U R U' R' U R U' R' f'",
                algorithm: "f (R U R' U') (R U R' U') f'"
            ),
            AlgorithmCase(
                name: "OLL 52",
                setupMoves: "R U R' U R d' R U' R' F'",
                algorithm: "(R U R' U) R d' R U' R' F'"
            ),
            AlgorithmCase(
                name: "OLL 55",
                setupMoves: "R U2 R2' U' R U' R' U2' F R F'",
                algorithm: "(R U2 R2' U') (R U' R' U2') (F R F')"
            ),
            AlgorithmCase(
                name: "OLL 56",
                setupMoves: "r U r' U R U' R' U R U' R' r U' r'",
                algorithm: "(r U r' U R U' R' U R U' R' r U' r')"
            )
        ]),
        AlgorithmSection(title: "All Corners Oriented", cases: [
            AlgorithmCase(
                name: "OLL 28 (Stealth)",
                setupMoves: "R U R' U' M' U R U' r'",
                algorithm: "(r U R' U') M (U R U' R')"
            ),
            AlgorithmCase(
                name: "OLL 57 (Stealth)",
                setupMoves: "R U R' U' M' U R U' r'",
                algorithm: "(R U R' U') M' (U R U' r')"
            )
        ])
    ]
    

    static let pllSections: [AlgorithmSection] = [
        AlgorithmSection(title: "Edges Only", cases: [
            AlgorithmCase(
                name: "Ua Perm",
                setupMoves: "M2' U' M' U2' M U' M2'",
                algorithm: "(M2 U M) U2 (M' U M2)"
            ),
            AlgorithmCase(
                name: "Ub Perm",
                setupMoves: "M2' U M' U2' M U M2'",
                algorithm: "(M2 U' M) U2 (M' U' M2)"
            ),
            AlgorithmCase(
                name: "H Perm",
                setupMoves: "M2' U' M2' U2' M2' U' M2'",
                algorithm: "M2' U M2' U2 M2' U M2'"
            ),
            AlgorithmCase(
                name: "Z Perm",
                setupMoves: "M U2' M2' U2' M U' M2' U' M2'",
                algorithm: "(M2 U) (M2 U) (M' U2) (M2 U2) (M' U2)"
            )
        ]),
        AlgorithmSection(title: "Corners Only", cases: [
            AlgorithmCase(
                name: "Aa Perm",
                setupMoves: "x R2' D2' R U R' D2' R U' R x'",
                algorithm: "x (R' U R') D2 (R U' R') D2 R2 x'"
            ),
            AlgorithmCase(
                name: "Ab Perm",
                setupMoves: "x R' U R' D2' R U' R' D2' R2' x'",
                algorithm: "x R2 D2 (R U R') D2 (R U' R) x'"
            ),
            AlgorithmCase(
                name: "E Perm",
                setupMoves: "x' D R U R' D' R U' R' D R U' R' D' R U R' x y'",
                algorithm: "y x' (R U' R' D) (R U R' D') (R U R' D) (R U' R' D') x"
            )
        ]),
        AlgorithmSection(title: "Adjacent Corner Swap", cases: [
            AlgorithmCase(
                name: "T Perm",
                setupMoves: "R U R' U' R' F R2 U' R' U' R U R' F'",
                algorithm: "(R U R' U') (R' F R2) (U' R' U') (R U R' F')"
            ),
            AlgorithmCase(
                name: "F Perm",
                setupMoves: "R' U' R U' R' U R U R2' F' R U R U' R' F U R y'",
                algorithm: "(R' U' F') (R U R' U') R' F R2 (U' R' U') (R U R' U) R"
            ),
            AlgorithmCase(
                name: "Ja Perm",
                setupMoves: "L' R' U2' R U R' U2' L U' R y'",
                algorithm: "y (R' U L') U2 (R U' R') U2 R L"
            ),
            AlgorithmCase(
                name: "Jb Perm",
                setupMoves: "R U R2' F' R U R U' R' F R U' R'",
                algorithm: "(R U R' F') (R U R' U') R' F R2 U' R'"
            ),
            AlgorithmCase(
                name: "Ra Perm",
                setupMoves: "R U' R' U' R U R D R' U' R D' R' U2 R'",
                algorithm: "(R U' R' U') (R U R D) (R' U' R D') R' U2 R'"
            ),
            AlgorithmCase(
                name: "Rb Perm",
                setupMoves: "R2 F R U R U' R' F' R U2 R' U2 R",
                algorithm: "(R' U2 R U2) R' F (R U R' U') R' F' R2"
            ),
            AlgorithmCase(
                name: "Y Perm",
                setupMoves: "F R U' R' U' R U R' F' R U R' U' R' F R F'",
                algorithm: "F R U' R' U' R U R' F' (R U R' U') (R' F R F')"
            )
        ]),
        AlgorithmSection(title: "Diagonal Corner Swap", cases: [
            AlgorithmCase(
                name: "Na Perm",
                setupMoves: "R U R' U R U R' F' R U R' U' R' F R2 U' R' U2 R U' R'",
                algorithm: "(R U R' U) (R U R' F' R U R' U' R' F R2 U' R') U2 R U' R'"
            ),
            AlgorithmCase(
                name: "Nb Perm",
                setupMoves: "F r' F' r U r U' r2' D' F r U r' F' D r",
                algorithm: "(R' U R U' R') (F' U' F) (R U R') (F R' F') (R U' R)"
            ),
            AlgorithmCase(
                name: "V Perm",
                setupMoves: "D2' R' U R D' R2' U' R' U R' U R' D' R U2' R'",
                algorithm: "(R' U R' U') (R D' R' D) (R' U D') (R2 U' R2) D R2"
            )
        ]),
        AlgorithmSection(title: "G Permutations", cases: [
            AlgorithmCase(
                name: "Ga Perm",
                setupMoves: "R' U' R D' U R2' U R' U R U' R U' R2' D",
                algorithm: "R2 (U R' U R' U' R U') R2 D (U' R' U R) D'"
            ),
            AlgorithmCase(
                name: "Gb Perm",
                setupMoves: "R2' U R' U R' U' R U' R2' D U' R' U R D'",
                algorithm: "(R' U' R U) D' R2 (U R' U R U' R U') R2 D"
            ),
            AlgorithmCase(
                name: "Gc Perm",
                setupMoves: "D' R U R' U' D R2' U' R U' R' U R' U R2'",
                algorithm: "R2 (U' R U' R U R' U) R2 D' (U R U' R') D"
            ),
            AlgorithmCase(
                name: "Gd Perm",
                setupMoves: "R2' U' R U' R U R' U R2' D' U R U' R' D",
                algorithm: "(R U R' U') D R2 (U' R U' R' U R' U) R2 D'"
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
