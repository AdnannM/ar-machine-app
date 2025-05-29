//
//  ARViewController+CameraButtonsDelegate.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension makes ARViewController conform to the CameraButtonsDelegate protocol.
         It handles user interactions with camera buttons, such as taking photos, starting/stopping video recordings,
         and presenting previews. It also sets up Combine-based bindings to update the UI based on
         recording status, captured previews, and content type changes from the ViewModel.
*/

import UIKit

// MARK: - Updated Camera Button Delegate

extension ARViewController: CameraButtonsDelegate {
    func cameraButtonPressed() {
        print("DEBUG: Camera button pressed!")
        takePhoto()
    }
    
    func cameraRecordingButtonPressed() {
        viewModel.toggleRecording()
    }
    
    func previewImageTapped() {
        presentPreviewController()
    }
    
    // MARK: - Helpers
    func setupViewModelBindings() {
        // Observe thumbnail changes
        viewModel.$previewThumbnail
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main) // Add debounce
            .sink { [weak self] thumbnail in
                guard let self = self else { return }
                self.cameraButton.updatePreviewImage(image: thumbnail)
                print("DEBUG: ARVC received thumbnail update from VM, updating button.")
            }
            .store(in: &cancellables)
        
        // Observe recording state changes
        viewModel.$isRecording
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(20), scheduler: RunLoop.main) // Lower debounce for UI responsiveness
            .sink { [weak self] isRec in
                guard let self = self else { return }
                self.cameraButton.setRecordingState(isRecording: isRec)
                
                // Update UI/logs based on recording state
                if isRec {
                    self.arDisplayView.showLog("🔴 Recording started...", duration: 2.0)
                } else if !isRec && self.viewModel.getCurrentContentType() == .video {
                    self.arDisplayView.showLog("✅ Video saved!", duration: 2.0)
                }
                
                print("DEBUG: ARVC received isRecording update from VM, updating button.")
            }
            .store(in: &cancellables)
        
        // Observe content type changes
        viewModel.$contentType
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main) // Add debounce
            .sink { [weak self] contentType in
                guard let _ = self else { return }
                print("DEBUG: ARVC received content type update from VM: \(contentType)")
                // Implement any specific UI updates related to content type changes here
            }
            .store(in: &cancellables)
    }
    
    private func takePhoto() {
        arDisplayView.showLog("📸 Taking photo...")
        
        // Consider moving the snapshot processing to a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let capturedImage: UIImage = self.arDisplayView.arView.snapshot()
            
            DispatchQueue.main.async {
                print("DEBUG: Photo captured successfully!")
                self.arDisplayView.showLog("✅ Photo captured!", duration: 2.0)
                self.viewModel.handleCapturedImage(capturedImage)
            }
        }
    }
}
