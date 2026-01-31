
//
//  FloatingPreviewManager.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import UIKit
import SwiftUI

class FloatingPreviewManager: ObservableObject {
    static let shared = FloatingPreviewManager()
    
    private var floatingWindow: UIWindow?
    private var floatingController: FloatingPreviewController?
    
    // We keep track of the current scramble state
    @Published var currentCubeState: CubeState?
    
    private init() {}
    
    func show(with state: CubeState) {
        self.currentCubeState = state
        
        if floatingWindow == nil {
            createFloatingWindow()
        }
        
        floatingWindow?.isHidden = false
        floatingController?.update(with: state)
    }
    
    func hide() {
        floatingWindow?.isHidden = true
        currentCubeState = nil
    }
    
    func toggle(with state: CubeState) {
        if floatingWindow?.isHidden == false {
            hide()
        } else {
            show(with: state)
        }
    }
    
    private func createFloatingWindow() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        // Create a new window for the floating view
        let window = PassthroughWindow(windowScene: windowScene)
        window.windowLevel = .alert + 1 // Show above everything
        window.backgroundColor = .clear
        
        let controller = FloatingPreviewController()
        window.rootViewController = controller
        
        self.floatingWindow = window
        self.floatingController = controller
    }
}

class FloatingPreviewController: UIViewController {
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var snapBehavior: UISnapBehavior?
    private var attachmentBehavior: UIAttachmentBehavior?
    private var itemBehavior: UIDynamicItemBehavior!
    
    private var floatingView: UIView!
    private var hostingController: UIHostingController<CubeMapPreview>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupFloatingView()
        setupGestureRecognizers()
        setupDynamics()
    }
    
    private func setupFloatingView() {
        let size = CGSize(width: 200, height: 160) // Approximate size for the net
        let startFrame = CGRect(x: view.bounds.width - size.width - 20,
                                y: 100,
                                width: size.width,
                                height: size.height)
        
        floatingView = UIView(frame: startFrame)
        floatingView.backgroundColor = .clear
        floatingView.layer.shadowColor = UIColor.black.cgColor
        floatingView.layer.shadowOpacity = 0.3
        floatingView.layer.shadowOffset = CGSize(width: 0, height: 4)
        floatingView.layer.shadowRadius = 8
        
        view.addSubview(floatingView)
    }
    
    func update(with state: CubeState) {
        // Remove old hosting controller if exists
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Create new
        let previewView = CubeMapPreview(state: state)
        let hc = UIHostingController(rootView: previewView)
        hc.view.backgroundColor = UIColor.clear
        hc.view.frame = floatingView.bounds
        hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hc)
        floatingView.addSubview(hc.view)
        hc.didMove(toParent: self)
        
        hostingController = hc
    }
    
    private func setupDynamics() {
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        // Add some physics properties
        itemBehavior = UIDynamicItemBehavior(items: [floatingView])
        itemBehavior.elasticity = 0.4
        itemBehavior.resistance = 5 // Damping
        itemBehavior.friction = 0
        itemBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(itemBehavior)
        
        snapToNearestCorner()
    }
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        floatingView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        
        switch gesture.state {
        case .began:
            // Remove snap when dragging starts
            if let snap = snapBehavior {
                dynamicAnimator.removeBehavior(snap)
            }
            
            // Create attachment for dragging
            let offset = UIOffset(horizontal: location.x - floatingView.center.x,
                                  vertical: location.y - floatingView.center.y)
            attachmentBehavior = UIAttachmentBehavior(item: floatingView, offsetFromCenter: offset, attachedToAnchor: location)
            dynamicAnimator.addBehavior(attachmentBehavior!)
            
        case .changed:
            attachmentBehavior?.anchorPoint = location
            
        case .ended, .cancelled:
            if let attachment = attachmentBehavior {
                dynamicAnimator.removeBehavior(attachment)
            }
            
            // Add momentum/velocity logic if desired, but for FaceTime-like behavior, we usually snap to nearest corner
            let velocity = gesture.velocity(in: view)
            itemBehavior.addLinearVelocity(velocity, for: floatingView)
            
            // Delay the snap slightly to let momentum carry it a bit, or snap immediately
            // FaceTime usually carries momentum then snaps.
            // Simplified approach: snap to nearest corner
            snapToNearestCorner()
            
        default: break
        }
    }
    
    private func snapToNearestCorner() {
        // Calculate nearest corner with some margin
        let margin: CGFloat = 20
        let viewSize = floatingView.bounds.size
        let safeArea = view.safeAreaInsets
        
        // Define corner positions
        let corners: [CGPoint] = [
            CGPoint(x: margin + viewSize.width/2, y: safeArea.top + margin + viewSize.height/2), // Top-Left
            CGPoint(x: view.bounds.width - margin - viewSize.width/2, y: safeArea.top + margin + viewSize.height/2), // Top-Right
            CGPoint(x: margin + viewSize.width/2, y: view.bounds.height - safeArea.bottom - margin - viewSize.height/2), // Bottom-Left
            CGPoint(x: view.bounds.width - margin - viewSize.width/2, y: view.bounds.height - safeArea.bottom - margin - viewSize.height/2) // Bottom-Right
        ]
        
        // Find closest
        let currentCenter = floatingView.center // Approximate where it will be
        // Better: Project where it would end up with current velocity?
        // For now, just use current position for simplicity of "snap on release"
        
        let closestCorner = corners.min(by: {
            distance($0, currentCenter) < distance($1, currentCenter)
        }) ?? corners[0]
        
        snapBehavior = UISnapBehavior(item: floatingView, snapTo: closestCorner)
        snapBehavior?.damping = 0.6
        dynamicAnimator.addBehavior(snapBehavior!)
    }
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
    
    // Pass through touches that aren't on the floating view
    // Since this is a UIViewController, we don't override point(inside:).
    // The hit-testing logic is handled by the PassthroughWindow below.
}

// Custom Window class to pass touches through to the application window below
// except when they hit our specific floating view controller's content.
class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        // If the hit view is the root view of our simplified floating controller, return nil to pass through
        // We only want to capture if it hit the floatingView (or its subviews) itself
        if view == rootViewController?.view {
            return nil
        }
        return view
    }
}
