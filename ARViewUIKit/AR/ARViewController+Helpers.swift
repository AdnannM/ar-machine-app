//
//  ARViewController+Helpers.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension adds helper methods to ARViewController.
         It handles presenting sheet controllers, showing and hiding control buttons,
         managing right bar button visibility, and transitioning between different 3D model views.
*/

import UIKit
import SwiftUI

// MARK: - Helpers

extension ARViewController {
    
    // MARK: - Present Sheet Controllers
    func presentArrowController() {
        let vc = AddArrowsController()
        presentAsSheet(vc, detents: [.medium(), .large()])
    }
    
    func presentSignController() {
        let vc = AddSignController()
        presentAsSheet(vc, detents: [.medium(), .large()])
    }
    
    func presentPdfController() {
        pdfView.isHidden.toggle()
    }
    
    func presentInfoController() {
        let vc = AddInfoController()
        presentAsSheet(vc, detents: [.large()])
    }

    func presentPreviewController() {
         let vc = PreviewImageController()

         switch viewModel.getCurrentContentType() {
         case .photo:
             guard let fullImage = viewModel.getFullImage() else {
                 print("DEBUG: ViewModel did not provide a full image.")
                 return
             }
             vc.imageToShow = fullImage

         case .video:
             // Request the video URL from the ViewModel
             guard let videoURL = viewModel.getVideoURL() else {
                 print("DEBUG: ViewModel did not provide a video URL.")
                 return
             }

             guard let thumbnail = viewModel.previewThumbnail else {
                print("DEBUG: ViewModel did not provide a video thumbnail.")
                 vc.videoPreviewThumbnail = nil
                 return
             }
           
             vc.videoURLToShow = videoURL
             vc.videoPreviewThumbnail = thumbnail
         }

          if let sheet = vc.sheetPresentationController {
              sheet.detents = [.large()]
              sheet.prefersGrabberVisible = false
          }
          present(vc, animated: true)
     }
    
    // MARK: - Show Buttons
    func showCameraButtons() {
        if isSHowingConrolButtons { hideControlButtons(animated: true) }
        hideRightBarButton(animated: true)
        
        showPartsButton.isHidden = true
        
        isShowingCameraButtons = true
        cameraButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.cameraButton.alpha = 1.0
        }
    }

    func showControlButtons() {
        if isShowingCameraButtons { hideCameraButtons(animated: true) }
        hideRightBarButton(animated: true)

        isSHowingConrolButtons = true
        controlButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.controlButton.alpha = 1.0
        }
    }

    // MARK: - Hide Buttons
    private func hideCameraButtons(animated: Bool) {
        let animations = {
            self.cameraButton.alpha = 0.0
        }
        let completion: (Bool) -> Void = { _ in
            self.cameraButton.isHidden = true
            self.isShowingCameraButtons = false
            self.isMenuOpened = false
        }

        animated ? UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
                 : { animations(); completion(true) }()
    }

    private func hideControlButtons(animated: Bool) {
        let animations = {
            self.controlButton.alpha = 0.0
        }
        let completion: (Bool) -> Void = { _ in
            self.controlButton.isHidden = true
            self.isSHowingConrolButtons = false
            self.isMenuOpened = false
        }

        animated ? UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
                 : { animations(); completion(true) }()
    }

    private func hideRightBarButton(animated: Bool) {
        guard !rightBarButton.isHidden else { return }

        isMenuOpened = false
        menuButton.setImage(UIImage(named: "menu"), for: .normal)

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.rightBarButton.alpha = 0.0
            } completion: { _ in
                self.rightBarButton.isHidden = true
            }
        } else {
            rightBarButton.alpha = 0.0
            rightBarButton.isHidden = true
        }
    }
    
    // MARK: - View Transitions (Add Views)
    
    func showMachineView() {
        addMachineView.isHidden = false
        addMachineView.alpha = 0.0
        view.bringSubviewToFront(addMachineView)
        UIView.animate(withDuration: 0.3) {
            self.addMachineView.alpha = 1.0
        }
    }
    
    func showObjectView() {
        addObjectView.isHidden = false
        addObjectView.alpha = 0.0
        view.bringSubviewToFront(addObjectView)
        UIView.animate(withDuration: 0.3) {
            self.addObjectView.alpha = 1.0
        }
    }
    
    func hideModelView(_ viewToHide: Add3DModelView) {
        UIView.animate(withDuration: 0.3) {
            viewToHide.alpha = 0.0
        } completion: { _ in
            viewToHide.isHidden = true
        }
    }
    
    // Hides all overlay views before showing a new one
    func hideAllAddViews() {
        if isShowingCameraButtons {
            hideCameraButtons(animated: true)
        }

        if !addMachineView.isHidden {
            hideModelView(addMachineView)
        }
        if !addObjectView.isHidden {
            hideModelView(addObjectView)
        }
        if !pdfView.isHidden {
            pdfView.isHidden = true
        }
    }
    
    // Add this to your Helpers extension for ARViewController
    func presentContactsController() {
        // Create a hosting controller for the SwiftUI view
        let contactsView = ContactsView()
        let hostingController = UIHostingController(rootView: contactsView)
        
        // Present as sheet with large detent
        presentAsSheet(hostingController, detents: [.large()])
    }
}
