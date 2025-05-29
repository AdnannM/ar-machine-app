//
//  ARViewController+ARCoachingOverlayViewDelegate.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension makes ARViewController conform to the ARCoachingOverlayViewDelegate protocol.
         It configures and manages the ARCoachingOverlayView, handling activation, deactivation,
         and session reset events to guide the user in finding a horizontal plane during an AR session.
         It also updates UI elements based on the coaching overlay’s visibility to enhance the AR experience.
*/

import ARKit
import UIKit
import os.log

extension ARViewController: ARCoachingOverlayViewDelegate {

    // Called from viewWillAppear AFTER arDisplayView.startSession()
    func setupCoachingOverlay() {
        coachingOverlay.delegate = self

        // Directly assign the session
        coachingOverlay.session = arDisplayView.arView.session

        coachingOverlay.activatesAutomatically = true   // first run only
        coachingOverlay.goal = .horizontalPlane
        os_log("Coaching Overlay setup complete.", log: .default, type: .info)
    }

    // ───────────── Overlay lifecycle ─────────────

    func coachingOverlayViewWillActivate(_ _: ARCoachingOverlayView) {
        menuButton.isHidden = true
        rightBarButton.isHidden = true
        cameraButton.isHidden = true
        controlButton.isHidden = true
        hideAllAddViews()
    }

    func coachingOverlayViewDidDeactivate(_ _: ARCoachingOverlayView) {
        menuButton.isHidden = false
        rightBarButton.isHidden = !isMenuOpened
        rightBarButton.alpha = isMenuOpened ? 1 : 0
    }

    /// User tapped “Reset” on the overlay → perform a **full** reset.
    func coachingOverlayViewDidRequestSessionReset(_ _: ARCoachingOverlayView) {
        os_log("Coaching Overlay requested session reset.", log: .default, type: .info)
        arDisplayView.startSession()
    }
}
