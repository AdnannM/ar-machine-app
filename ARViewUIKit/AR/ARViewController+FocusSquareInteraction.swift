//
//  ARViewController+FocusSquareInteraction.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension adds setup and tap gesture handling for the focus square in ARViewController.
         It enables adding the focus square to the scene, handling user taps to select a surface,
         and provides visual feedback.
*/

import ARKit
import UIKit
import os.log

extension ARViewController {

    func setupFocusSquare() {
        // Initially hide the focus square
        focusSquare.hide()

        // Add focus square to the scene
        arDisplayView.arView.scene.rootNode.addChildNode(focusSquare)

        os_log("Focus square added to scene", log: .default, type: .info)
    }
}
