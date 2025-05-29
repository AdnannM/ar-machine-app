//
//  ARViewController+LifecycleHandler.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension adds application lifecycle handling to ARViewController.
         It manages pausing the AR session when the app becomes inactive and
         resuming the AR session when the app becomes active again, ensuring
         proper AR experience continuity.
*/

import UIKit
import os.log

extension ARViewController {

    @objc func appWillResignActive() {
        os_log("App Will Resign Active - Pausing AR Session", log: .default, type: .info)
        // Pause the AR session when the app goes into the background
        // or becomes inactive (e.g., phone call)
        arDisplayView.pauseSession()
    }

    @objc func appDidBecomeActive() {
        os_log("App Did Become Active - Resuming AR Session", log: .default, type: .info)
        // Resume the AR session when the app becomes active again.
        // Ensure the view is visible before resuming.
        if isViewLoaded && view.window != nil {
            arDisplayView.resumeSession()
        } else {
            os_log("App Did Become Active - View not ready, delaying session resume.", log: .default, type: .info)
        }
    }
}
