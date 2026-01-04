//
//  CubeTypePicker.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct CubeTypePicker: View {
    @Binding var selectedType: CubeType
    var onChange: ((CubeType) -> Void)?
    
    @State private var isExpanded = false
    
    private let mainCubeTypes: [CubeType] = [.twoByTwo, .threeByThree, .fourByFour, .fiveByFive]
    
    var body: some View {
        Menu {
            ForEach(CubeType.allCases) { cubeType in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedType = cubeType
                        onChange?(cubeType)
                    }
                }) {
                    HStack {
                        Text(cubeType.displayName)
                        if cubeType == selectedType {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cube.fill")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(selectedType.displayName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.2, blue: 0.25),
                                Color(red: 0.15, green: 0.15, blue: 0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CubeTypePicker(selectedType: .constant(.threeByThree))
    }
}

