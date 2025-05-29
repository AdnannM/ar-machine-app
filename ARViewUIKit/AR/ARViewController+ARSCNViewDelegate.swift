//
//  ARViewController+ARSCNViewDelegate.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension makes ARViewController conform to ARSCNViewDelegate.
         It handles scene rendering, surface detection, focus square updates,
         and virtual object visibility checks.
*/

import ARKit
import os.log

extension ARViewController: ARSCNViewDelegate {
    func renderer(
        _ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor
    ) {
        guard anchor is ARPlaneAnchor else { return }

        DispatchQueue.main.async { [weak self] in
            self?.arDisplayView.showLog("🔎 Surface Detected")
            self?.focusSquare.unhide()
            self?.updateFocusSquare()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        let isAnyObjectInView = false  // Replace with actual object tracking

        DispatchQueue.main.async { [weak self] in
            self?.updateFocusSquare(isObjectVisible: isAnyObjectInView)
            
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // Only handle anchors you created for your model
        // (you could also tag them via a custom subclass or identifier)
        return currentlyManipulatedNode
    }
}
