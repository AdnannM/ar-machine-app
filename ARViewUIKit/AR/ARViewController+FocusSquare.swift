//
//  ARViewController+FocusSquare.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension adds focus square management functionality to ARViewController.
         It updates the visibility and state of the focus square based on ARKit
         tracking status, coaching overlay state, and raycasting results.
*/

import UIKit
import ARKit

extension ARViewController {

    func updateFocusSquare(isObjectVisible: Bool = false) {
        // Hide focus square if coaching overlay is active
        if coachingOverlay.isActive {
            focusSquare.hide()
            return
        }

        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }

        // Perform ray casting when ARKit tracking is in a good state
        guard let camera = arDisplayView.arView.session.currentFrame?.camera,
            case .normal = camera.trackingState
        else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.arDisplayView.arView.pointOfView?.addChildNode(
                    self.focusSquare)
            }
            return
        }

        // Create raycast query and perform raycast
        guard let query = arDisplayView.arView.getRaycastQuery(),
            let result = arDisplayView.arView.castRay(for: query).first
        else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.arDisplayView.arView.pointOfView?.addChildNode(
                    self.focusSquare)
            }
            return
        }

        updateQueue.async {
            self.arDisplayView.arView.scene.rootNode.addChildNode(
                self.focusSquare)
            self.focusSquare.state = .detecting(
                raycastResult: result, camera: camera)
        }
    }
}
