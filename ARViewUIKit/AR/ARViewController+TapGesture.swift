//
//  ARViewController.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 12.04.25.
//

import ARKit
import SceneKit
import UIKit
import RealityKit
import SpriteKit

// MARK: — SCNVector3 Arithmetic Helpers
private func + (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    SCNVector3(l.x + r.x, l.y + r.y, l.z + r.z)
}
private func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    SCNVector3(l.x - r.x, l.y - r.y, l.z - r.z)
}

// MARK: — Gesture Handling & Selection Extension
extension ARViewController: UIGestureRecognizerDelegate {

    // State for optimized pan
    private struct PanState {
        static var startScreenPoint: CGPoint?
        static var startWorldPosition: SCNVector3?
    }

    /// Call once in viewDidLoad()
    func setupGestures() {
        let configs: [(UIGestureRecognizer, Selector)] = [
            (UITapGestureRecognizer(), #selector(handleTap(_:))),
            (UIPanGestureRecognizer(), #selector(handlePan(_:))),
            (UIPinchGestureRecognizer(), #selector(handlePinch(_:))),
            (UIRotationGestureRecognizer(), #selector(handleRotation(_:))),
        ]

        for (recognizer, action) in configs {
            recognizer.addTarget(self, action: action)
            recognizer.delegate = self
            arDisplayView.addGestureRecognizer(recognizer)
        }
    }

    // MARK: — Helpers

    /// Climb node hierarchy until immediate child of scene.rootNode
    private func modelRoot(from node: SCNNode) -> SCNNode {
        var current = node
        while let parent = current.parent,
            parent != arDisplayView.arView.scene.rootNode
        {
            current = parent
        }
        return current
    }

    // MARK: — Gesture Handlers
    
    /// Removes any existing selection visuals from the scene
    private func clearSelectionHighlight() {
        // you can remove from the root to catch everything
        arDisplayView.arView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "selectionBox" || node.name == "selectionRing" {
                node.removeFromParentNode()
            }
        }
        currentlyManipulatedNode = nil
    }

    /// Called when the user taps
    @objc private func handleTap(_ g: UITapGestureRecognizer) {
        let pt = g.location(in: arDisplayView)
        
        // always clear the old highlight first
        clearSelectionHighlight()
        
        if let hit = arDisplayView.arView.hitTest(pt, options: nil).first {
            // we hit something—select it
            let root = modelRoot(from: hit.node)
            currentlyManipulatedNode = root
            highlightSelectedNode(on: root)
            print("Selected model: \(root.name ?? "unnamed")")
        } else {
            // tapped empty space: no selection
            arDisplayView.showLog("❓No model selected")
        }
    }

    
    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        // 1) Unwrap the selected node and your ARSCNView
        guard let node = currentlyManipulatedNode,
            let scnView = arDisplayView.arView
        else { return }

        switch g.state {
        case .began:
            // Store where your finger started, and the node’s world position
            PanState.startScreenPoint = g.location(in: arDisplayView)
            PanState.startWorldPosition = node.position

        case .changed:
            // 2) Unwrap those stored values
            guard let startPt = PanState.startScreenPoint,
                let startWorld = PanState.startWorldPosition
            else { return }

            // 3) Project the world-point to get its depth (z)
            let projected = scnView.projectPoint(startWorld)
            let depth = projected.z

            // 4) Build two 3D points at that same depth
            let screenStart = SCNVector3(
                Float(startPt.x),
                Float(startPt.y),
                depth)
            let screenNow = SCNVector3(
                Float(g.location(in: arDisplayView).x),
                Float(g.location(in: arDisplayView).y),
                depth)

            // 5) Unproject back into world space
            let worldStart = scnView.unprojectPoint(screenStart)
            let worldNow = scnView.unprojectPoint(screenNow)

            // 6) Move the node by the difference
            node.position = startWorld + (worldNow - worldStart)

        default:
            // Clean up when you lift your finger
            PanState.startScreenPoint = nil
            PanState.startWorldPosition = nil
        }
    }
    
    @objc private func handlePinch(_ g: UIPinchGestureRecognizer) {
        guard let node = currentlyManipulatedNode else { return }
        if g.state == .began {
            initialScaleForPinch = node.scale
        }
        guard let baseScale = initialScaleForPinch else { return }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.08
        let f = Float(g.scale)
        node.scale = SCNVector3(
            baseScale.x * f,
            baseScale.y * f,
            baseScale.z * f)
        SCNTransaction.commit()
    }

    @objc private func handleRotation(_ g: UIRotationGestureRecognizer) {
        guard let node = currentlyManipulatedNode else { return }
        switch g.state {
        case .began:
            initialYaw = node.eulerAngles.y
        case .changed:
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.08
            node.eulerAngles.y = initialYaw - Float(g.rotation)
            node.eulerAngles.x = 0  // lock pitch
            node.eulerAngles.z = 0  // lock roll
            SCNTransaction.commit()
        default: break
        }
    }

    // MARK: — Highlight Selection
    
    func highlightSelectedNode(on node: SCNNode) {
        // build the green wireframe box
        let (minV, maxV) = node.boundingBox
        let spanX = maxV.x - minV.x
        let spanY = maxV.y - minV.y
        let spanZ = maxV.z - minV.z

        let boxGeo = SCNBox(width:  CGFloat(spanX),
                            height: CGFloat(spanY),
                            length: CGFloat(spanZ),
                            chamferRadius: 0)
        boxGeo.firstMaterial?.diffuse.contents = UIColor.systemGreen
        boxGeo.firstMaterial?.fillMode = .lines
        boxGeo.firstMaterial?.lightingModel = .constant

        let boxNode = SCNNode(geometry: boxGeo)
        boxNode.name = "selectionBox"
        // center the box on the model
        boxNode.position = SCNVector3(
            (minV.x + maxV.x) * 0.5,
            (minV.y + maxV.y) * 0.5,
            (minV.z + maxV.z) * 0.5
        )
        node.addChildNode(boxNode)

        // if you still want the ring, you can build/add it here too…

        arDisplayView.showLog("✅ Selected model")
    }

    // MARK: — Allow Simultaneous Gestures
    func gestureRecognizer(
        _ g1: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith g2: UIGestureRecognizer
    ) -> Bool {
        true
    }
}



// MARK: - OLD CODE FOR SELECTING PARTS ON MACHINE

//extension ARViewController {
//    func setupGestures() {
//        // Pinch Gesture for Zoom
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        arDisplayView.arView.addGestureRecognizer(pinchGesture)
//
//        // Pan Gesture for Movement
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        arDisplayView.arView.addGestureRecognizer(panGesture)
//
//        // Rotation Gesture
//        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
//        arDisplayView.arView.addGestureRecognizer(rotationGesture)
//
//        // Tap Gesture for Selection
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        arDisplayView.arView.addGestureRecognizer(tapGesture)
//    }
//
//    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
//        guard let node = currentlyManipulatedNode else { return }
//
//        switch gesture.state {
//        case .began:
//            initialScaleForPinch = node.scale
//        case .changed:
//            guard let initialScale = initialScaleForPinch else { return }
//            let scale = Float(gesture.scale)
//            let newScale = SCNVector3(
//                initialScale.x * scale,
//                initialScale.y * scale,
//                initialScale.z * scale
//            )
//            node.scale = newScale
//        default:
//            break
//        }
//    }
//
//    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
//        guard let node = currentlyManipulatedNode else { return }
//
//        switch gesture.state {
//        case .began:
//            initialNodePosition = node.position
//        case .changed:
//            guard let hitTestResult = arDisplayView.arView.hitTest(
//                gesture.location(in: arDisplayView.arView),
//                types: .existingPlaneUsingExtent
//            ).first else { return }
//
//            let worldTransform = hitTestResult.worldTransform
//            let position = SCNVector3(
//                worldTransform.columns.3.x,
//                worldTransform.columns.3.y,
//                worldTransform.columns.3.z
//            )
//            node.position = position
//
//        default:
//            break
//        }
//    }
//
//    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
//        guard let node = currentlyManipulatedNode else { return }
//
//        switch gesture.state {
//        case .changed:
//            let rotation = Float(gesture.rotation)
//            node.eulerAngles.y = rotation
//            gesture.rotation = 0
//        default:
//            break
//        }
//    }
//
//    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
//        let location = gesture.location(in: arDisplayView.arView)
//        let hitTestResults = arDisplayView.arView.hitTest(location, options: nil)
//
//        if let hitNode = hitTestResults.first?.node {
//            // If we tap the same node again, deselect it
//            if hitNode == currentlyManipulatedNode {
//                currentlyManipulatedNode = nil
//                arDisplayView.showLog("Model deselected")
//            } else {
//                currentlyManipulatedNode = hitNode
//                arDisplayView.showLog("Model selected")
//            }
//        } else {
//            currentlyManipulatedNode = nil
//            arDisplayView.showLog("No model selected")
//        }
//    }
//}

// OLD METHOD CIRCLE ARROUND MODEL

//    private func highlightSelectedNode() {
//        guard let node = currentlyManipulatedNode else {
//            arDisplayView.showLog("No model selected")
//            return
//        }
//
//        // remove old ring + old box
//        node.childNode(withName: "selectionRing", recursively: false)?
//            .removeFromParentNode()
//        node.childNode(withName: "selectionBox",  recursively: false)?
//            .removeFromParentNode()
//
//        // 1) get the local bounding box
//        let (minV, maxV) = node.boundingBox
//        let spanX = maxV.x - minV.x
//        let spanY = maxV.y - minV.y
//        let spanZ = maxV.z - minV.z
//
//        // 2) create your ring (as before)…
////        let radius = (max(spanX, spanZ) / 2) * 1.1
////        let torus = SCNTorus(ringRadius: CGFloat(radius),
////                             pipeRadius: CGFloat(radius * 0.02))
////        torus.firstMaterial?.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.8)
////        torus.firstMaterial?.lightingModel = .constant
////        let ringNode = SCNNode(geometry: torus)
////        ringNode.name = "selectionRing"
////        ringNode.opacity = 0
////        ringNode.eulerAngles.x = -.pi/2
////        // place at local bottom‐center
////        ringNode.position = SCNVector3(
////            (minV.x + maxV.x) * 0.5,
////            minV.y + 0.005,
////            (minV.z + maxV.z) * 0.5
////        )
////        node.addChildNode(ringNode)
////        ringNode.runAction(.fadeIn(duration: 0.2))
//
//        // 3) build the *box*
//        let boxGeo = SCNBox(width:  CGFloat(spanX),
//                            height: CGFloat(spanY),
//                            length: CGFloat(spanZ),
//                            chamferRadius: 0)
//        // wireframe style
//        boxGeo.firstMaterial?.diffuse.contents = UIColor.systemGreen
//        boxGeo.firstMaterial?.fillMode = .lines
//        boxGeo.firstMaterial?.lightingModel = .constant
//
//        let boxNode = SCNNode(geometry: boxGeo)
//        boxNode.name = "selectionBox"
//        // center of the box = midpoint of the bounding‐box
//        boxNode.position = SCNVector3(
//            (minV.x + maxV.x) * 0.5,
//            (minV.y + maxV.y) * 0.5,
//            (minV.z + maxV.z) * 0.5
//        )
//        node.addChildNode(boxNode)
//
//        arDisplayView.showLog("Selected model")
//    }
