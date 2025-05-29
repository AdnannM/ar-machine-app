//
//  ARViewController+ArrowLoaderDelegate.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 23.05.25.
//

import UIKit
import SceneKit

// Error types for arrow loading
enum ArrowLoadError: Error {
    case missingUSDZFile
    case referenceNodeFailed
}

// Delegate to notify UI or controller of load failure
protocol ArrowLoaderDelegate: AnyObject {
    func didFailToLoadArrow(reason: String)
}

// Protocol to abstract arrow animation for testability
protocol ArrowAnimatable {
    func runBounceAnimation(height: CGFloat)
}

extension SCNNode: ArrowAnimatable {
    func runBounceAnimation(height: CGFloat) {
        let dy = height * 0.15
        let up = SCNAction.moveBy(x: 0, y: dy, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        runAction(.repeatForever(.sequence([up, up.reversed()])))
    }
}


// =============================================================
//  MARK: – Arrow Helpers
// =============================================================
extension ARViewController: ArrowLoaderDelegate {
    
    // MARK: - Constants

    private var baseArrowScale: Float { return 0.03 }
   
    // MARK: - Arrow Helpers

    /// Loads the Arrow.usdz file and creates a prototype node for reuse.
    func loadArrowPrototype() throws {
        guard arrowPrototype == nil,
              let url = Bundle.main.url(forResource: "Arrow", withExtension: "usdz") else {
            throw ArrowLoadError.missingUSDZFile
        }

        guard let ref = SCNReferenceNode(url: url) else {
            throw ArrowLoadError.referenceNodeFailed
        }

        ref.load()
        ref.name = "ArrowPrototype"
        ref.scale = SCNVector3(baseArrowScale, baseArrowScale, baseArrowScale)
        arrowPrototype = ref
    }

    /// Safely loads the arrow prototype and notifies delegate on error.
    func initializeArrow() {
        do {
            try loadArrowPrototype()
        } catch {
            arrowDelegate?.didFailToLoadArrow(reason: error.localizedDescription)
        }
    }

    /// Attaches an animated arrow above the given node.
    func attachArrow(to part: SCNNode) {
        guard arrows[part] == nil, let proto = arrowPrototype else { return }

        let arrow = proto.clone()
        arrow.name = "IndicatorArrow"

        let (position, scale, height) = computeArrowPlacement(for: part)
        arrow.position = position
        arrow.scale = scale
        arrow.runBounceAnimation(height: CGFloat(height))

        part.addChildNode(arrow)
        arrows[part] = arrow
    }

    /// Detaches the arrow from a node if it exists.
    func detachArrow(from part: SCNNode) {
        arrows[part]?.removeFromParentNode()
        arrows[part] = nil
        bounceActions[part] = nil
    }

    /// Removes all arrows from the scene and clears tracking.
    func removeAllArrows() {
        arrows.values.forEach { $0.removeFromParentNode() }
        arrows.removeAll()
        bounceActions.removeAll()
    }

    /// Hides the currently active arrow.
    func hideArrow() {
        activeArrowNode?.removeFromParentNode()
        activeArrowNode = nil
    }

    /// Calculates arrow position, scale, and height based on bounding box.
    private func computeArrowPlacement(for node: SCNNode) -> (SCNVector3, SCNVector3, Float) {
        let (minB, maxB) = node.boundingBox
        let h = maxB.y - minB.y

        let position = SCNVector3(
            (minB.x + maxB.x) * 0.5,
            maxB.y + h * 0.2,
            (minB.z + maxB.z) * 0.5
        )

        let maxDim = max(h, maxB.x - minB.x, maxB.z - minB.z)
        let scaleVal = maxDim * 0.3
        let scale = SCNVector3(scaleVal, scaleVal, scaleVal)

        return (position, scale, h)
    }
    
    func didFailToLoadArrow(reason: String) {
        print("⚠️ Arrow failed to load: \(reason)")
    }
}
