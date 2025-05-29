//
//  ARViewController+RightBarButtonsDelegate.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension makes ARViewController conform to RightBarButtonsDelegate.
         It handles user interactions with the right bar buttons, including adding 3D models,
         opening the camera, activating LIDAR scanning, sending PDFs, and presenting project information.
*/

import UIKit

// MARK: -  RightBarButtonsProtocol

extension ARViewController: RightBarButtonsDelegate {
    func didTapAddButton() {
        arDisplayView.showLog("🆕 3D Model Added.")
        hideAllAddViews()
        showMachineView()
    }
    
    func didTapAddArrowButton() {
        arDisplayView.showLog("➡️ Arrow Added.")
        hideAllAddViews()
        showObjectView()
    }
    
    func didTapAddCubeButton() {
        arDisplayView.showLog("🧊 Cube Added.")
        // Optional: Add cube logic here
    }
    
    func didTapSignButton() {
        arDisplayView.showLog("🔖 Sign Added.")
        hideAllAddViews()
        presentSignController()
    }
    
    func didTapLidarScannerButton() {
        arDisplayView.showLog("📡 LIDAR Scanner Activated.")
        // Optional: LIDAR logic
    }
    
    func didTapCameraButton() {
        arDisplayView.showLog("📷 Camera Opened.")
        hideAllAddViews()
        showCameraButtons()
    }
    
    func didTapPdfButton() {
        arDisplayView.showLog("📄 PDF Sent.")
        hideAllAddViews()
        presentPdfController()
    }
    
    func didTapContactButton() {
        arDisplayView.showLog("📞 Contact Info Shown.")
        
        hideAllAddViews()
        presentContactsController()
    }
    
    func didTapInfoButton() {
        arDisplayView.showLog("ℹ️ Project Information Opened.")
        hideAllAddViews()
        presentInfoController()
    }
}
