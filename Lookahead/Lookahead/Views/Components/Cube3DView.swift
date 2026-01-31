
//
//  Cube3DView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI
import SceneKit

struct Cube3DView: UIViewRepresentable {
    let state: CubeState
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor.clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        
        // Setup scene
        scnView.scene = createScene()
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Optimisation: Only update if state changed significantly? 
        // For now, simple recreation is fine as it's a sheet.
        uiView.scene = createScene()
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // Camera (optional, allowsCameraControl handles default nicely)
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 5, y: 5, z: 8)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(cameraNode)
        
        // Build the cube
        let n = state.size
        let offset = Float(n - 1) * 0.5 // To center the cube at 0,0,0
        let boxSize: CGFloat = 0.95 // Slightly smaller than 1.0 to show gaps (like real cubes)
        
        // Loop through the 3D grid
        // Our coordinate system:
        // x: Left (-) to Right (+)
        // y: Down (-) to Up (+)
        // z: Back (-) to Front (+)
        
        for x in 0..<n {
            for y in 0..<n {
                for z in 0..<n {
                    // Create box
                    let box = SCNBox(width: boxSize, height: boxSize, length: boxSize, chamferRadius: 0.05)
                    
                    // Materials order: Front, Right, Back, Left, Top, Bottom
                    var materials: [SCNMaterial] = []
                    
                    // Front Face (Z+)
                    materials.append(materialFor(face: .front, isActive: z == n-1, x: x, y: y))
                    
                    // Right Face (X+)
                    materials.append(materialFor(face: .right, isActive: x == n-1, x: n-1-z, y: y)) // Coord mapping tricky here
                    
                    // Back Face (Z-)
                    materials.append(materialFor(face: .back, isActive: z == 0, x: n-1-x, y: y))
                    
                    // Left Face (X-)
                    materials.append(materialFor(face: .left, isActive: x == 0, x: z, y: y))
                    
                    // Top Face (Y+)
                    materials.append(materialFor(face: .up, isActive: y == n-1, x: x, y: n-1-z))
                    
                    // Bottom Face (Y-)
                    materials.append(materialFor(face: .down, isActive: y == 0, x: x, y: z))

                    box.materials = materials
                    
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(
                        Float(x) - offset,
                        Float(y) - offset,
                        Float(z) - offset
                    )
                    
                    scene.rootNode.addChildNode(node)
                }
            }
        }
        
        return scene
    }
    
    // Mapping 3D grid coords to 2D face grid coords
    // state.faces stores [row][col]
    // Standard approach:
    // U/D: viewed from top/bottom.
    // F/B/L/R viewed from outside.
    private func materialFor(face: CubeFace, isActive: Bool, x: Int, y: Int) -> SCNMaterial {
        let material = SCNMaterial()
        
        if isActive {
            // Need to map the local x,y on that face to the global row/col in our data model
            // Our model is simplified: [row][col]. Usually row 0 is top.
            
            // Map logic needs to be precise to match CubeState logic.
            // Let's defer exact mapping for a moment and assume direct correlation for now to get visuals up,
            // but we must try to be correct.
            /*
             CubeState (FaceView logic):
             row 0 is top of the face visual.
             
             In 3D loop:
             x increases Left -> Right.
             y increases Bottom -> Top.
             
             So generally:
             col (0..n-1) ~ x
             row (0..n-1) ~ (n-1-y) (since row 0 is top)
            */
            
            let row = state.size - 1 - y
            let col = x
            
            // Safety check
            if row >= 0 && row < state.size && col >= 0 && col < state.size {
                let color = state.faces[face]?[row][col] ?? .black
                material.diffuse.contents = UIColor(color)
            } else {
                material.diffuse.contents = UIColor.black
            }
        } else {
            // Internal face
            material.diffuse.contents = UIColor.black
        }
        
        return material
    }
}
