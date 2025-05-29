//
//  ARViewController+MediaCapture.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension adds media capture setup functionalities to ARViewController.
         It configures video recording, checks photo library permissions, sets up camera button delegates,
         and binds ViewModel updates for responsive UI interactions related to photo and video capturing.
*/

import Photos
import UIKit

// MARK: - ViewController Setup

extension ARViewController {
    func setupVideoRecording() {
        // Initialize video recorder in the ViewModel
        viewModel.setupVideoRecorder(for: arDisplayView.arView)
    }

    func configureForMediaCapture() {
        // Setup permission requests
        checkPhotoLibraryPermissions()

        // Setup video recording
        setupVideoRecording()

        // Setup camera button actions
        setupCameraButtons()

        // Setup bindings to react to ViewModel changes
        setupViewModelBindings()
    }

    private func setupCameraButtons() {
        cameraButton.delegate = self
    }

    private func checkPhotoLibraryPermissions() {
        // Check for photo library permissions (needed for saving)
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("DEBUG: Photo library access granted")
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.arDisplayView.showLog(
                        "⚠️ Photo access denied. Cannot save media.",
                        duration: 3.0)
                }
            case .notDetermined:
                print("DEBUG: Photo library access not determined yet")
            case .limited:
                print("DEBUG: Limited photo library access granted")
            @unknown default:
                print("DEBUG: Unknown photo library access status")
            }
        }
    }
}
