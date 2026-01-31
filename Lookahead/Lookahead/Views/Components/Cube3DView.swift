
//
//  Cube3DView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI
import SceneKit

struct Cube3DView: View {
    let state: CubeState
    var interactive: Bool = true
    @State private var resetID = UUID()
    @State private var hasInteracted: Bool = false
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Cube3DRepresentable(
                state: state,
                interactive: interactive,
                resetTrigger: resetID,
                hasInteracted: $hasInteracted
            )
            .id(resetID)
            
            if interactive && hasInteracted {
                Button {
                    withAnimation {
                        resetID = UUID()
                        hasInteracted = false
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(themeManager.colors.light)
                        .frame(width: 32, height: 32)
                        .background(themeManager.colors.dark.opacity(0.6))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(themeManager.colors.light.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(8)
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
}

// Fixed implementation below incorporating the plan
struct Cube3DRepresentable: UIViewRepresentable {
    let state: CubeState
    var interactive: Bool = true
    var resetTrigger: UUID = UUID()
    @Binding var hasInteracted: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: Cube3DRepresentable
        var lastResetTrigger: UUID?
        
        // Initial camera parameters to compare against
        let initialPosition = SCNVector3(x: 5, y: 5, z: 8)
        let initialLookAt = SCNVector3(x: 0, y: 0, z: 0) // For valid check we might need camera orientation
        
        init(parent: Cube3DRepresentable) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard parent.interactive, !parent.hasInteracted else { return }
            
            guard let pointOfView = renderer.pointOfView else { return }
            
            // Check position difference
            let pos = pointOfView.presentation.position
            let diffX = abs(pos.x - initialPosition.x)
            let diffY = abs(pos.y - initialPosition.y)
            let diffZ = abs(pos.z - initialPosition.z)
            
            // Threshold for movement detection
            let threshold: Float = 0.1
            
            if diffX > threshold || diffY > threshold || diffZ > threshold {
                DispatchQueue.main.async {
                    if !self.parent.hasInteracted {
                        self.parent.hasInteracted = true
                    }
                }
            }
        }
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor.clear
        // Set allowsCameraControl initially, but we might need to toggle it to reset smoothly?
        // Usually setting pointOfView works active control.
        scnView.allowsCameraControl = interactive
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = context.coordinator
        
        let scene = SCNScene()
        setupCamera(in: scene)
        updateCubeNodes(in: scene)
        
        scnView.scene = scene
        context.coordinator.lastResetTrigger = resetTrigger
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update parent reference in coordinator
        context.coordinator.parent = self
        
        guard let scene = uiView.scene else { return }
        
        // 1. Check for Reset
        if context.coordinator.lastResetTrigger != resetTrigger {
            // Reset Camera
            if let cameraNode = scene.rootNode.childNode(withName: "MainCamera", recursively: false) {
                // Reset internal camera controller if interactive
                if interactive {
                    uiView.defaultCameraController.pointOfView = nil // Reset to nil first sometimes helps?
                    // Actually, setting pointOfView to our cameraNode snaps it back.
                    uiView.pointOfView = cameraNode
                }
                
                // Reset node transform just in case
                cameraNode.position = SCNVector3(x: 5, y: 5, z: 8)
                cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
            }
            context.coordinator.lastResetTrigger = resetTrigger
            
            // Ensure interaction state is synced if reset came from valid trigger
             DispatchQueue.main.async {
                 if self.hasInteracted {
                     self.hasInteracted = false
                 }
             }
        }
        
        // 2. Update Cube Content (Always update for now, or check state equality if costly)
        // Since we are not recreating the scene, we should remove old cube nodes and add new ones.
        // Optimization: Assigning a unique name to the container node of the cube.
        if let container = scene.rootNode.childNode(withName: "CubeContainer", recursively: false) {
            container.removeFromParentNode()
        }
        updateCubeNodes(in: scene)
    }
    
    private func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.name = "MainCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 5, y: 5, z: 8)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func updateCubeNodes(in scene: SCNScene) {
        let containerNode = SCNNode()
        containerNode.name = "CubeContainer"
        
        let n = state.size
        let offset = Float(n - 1) * 0.5
        let boxSize: CGFloat = 0.95
        
        for x in 0..<n {
            for y in 0..<n {
                for z in 0..<n {
                    let box = SCNBox(width: boxSize, height: boxSize, length: boxSize, chamferRadius: 0.05)
                    var materials: [SCNMaterial] = []
                    
                    // Front (Z+)
                    materials.append(materialFor(face: .front, isActive: z == n-1, x: x, y: y))
                    // Right (X+)
                    materials.append(materialFor(face: .right, isActive: x == n-1, x: n-1-z, y: y))
                    // Back (Z-)
                    materials.append(materialFor(face: .back, isActive: z == 0, x: n-1-x, y: y))
                    // Left (X-)
                    materials.append(materialFor(face: .left, isActive: x == 0, x: z, y: y))
                    // Top (Y+)
                    materials.append(materialFor(face: .up, isActive: y == n-1, x: x, y: n-1-z))
                    // Bottom (Y-)
                    materials.append(materialFor(face: .down, isActive: y == 0, x: x, y: z))

                    box.materials = materials
                    
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(
                        Float(x) - offset,
                        Float(y) - offset,
                        Float(z) - offset
                    )
                    
                    containerNode.addChildNode(node)
                }
            }
        }
        
        scene.rootNode.addChildNode(containerNode)
    }
    
    private func materialFor(face: CubeFace, isActive: Bool, x: Int, y: Int) -> SCNMaterial {
        let material = SCNMaterial()
        
        if isActive {
            let row = state.size - 1 - y
            let col = x
            
            if row >= 0 && row < state.size && col >= 0 && col < state.size {
                let color = state.faces[face]?[row][col] ?? .black
                material.diffuse.contents = UIColor(color)
            } else {
                material.diffuse.contents = UIColor.black
            }
        } else {
            material.diffuse.contents = UIColor.black
        }
        
        return material
    }
}
