//
//  ARViewController+Layout.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
    Abstract:
        This extension manages the layout setup for all major UI components in ARViewController.
        It configures the Auto Layout constraints for various elements such as the AR view, camera button,
        control buttons, machine and object views, PDF view, and coaching overlay.
        Each UI component has its own layout function for clear separation of concerns,
        with the `layout()` method acting as the central entry point to apply all constraints.
        This structure ensures a responsive and organized layout for the AR interface.
*/


import UIKit

extension ARViewController {
    func layout() {
        layoutMenuButton()
        layoutRightBarButton()
        layoutARView()
        layoutCameraButton()
        layoutControlButton()
        layoutAddMachineView()
        layoutAddObjectView()
        layoutPdfView()
        layoutCoachingOverlay()
        layoutShowPartsButton()
    }

    private func layoutMenuButton() {
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            menuButton.heightAnchor.constraint(equalToConstant: 40),
            menuButton.widthAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func layoutRightBarButton() {
        NSLayoutConstraint.activate([
            rightBarButton.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 25),
            rightBarButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
        ])
    }

    private func layoutARView() {
        NSLayoutConstraint.activate([
            arDisplayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arDisplayView.topAnchor.constraint(equalTo: view.topAnchor),
            arDisplayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arDisplayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func layoutCameraButton() {
        NSLayoutConstraint.activate([
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraButton.heightAnchor.constraint(equalToConstant: 180),
        ])
    }

    private func layoutControlButton() {
        NSLayoutConstraint.activate([
            controlButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }

    private func layoutAddMachineView() {
        NSLayoutConstraint.activate([
            addMachineView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addMachineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addMachineView.trailingAnchor.constraint(equalTo: rightBarButton.leadingAnchor, constant: -10),
        ])
    }

    private func layoutAddObjectView() {
        NSLayoutConstraint.activate([
            addObjectView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addObjectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addObjectView.trailingAnchor.constraint(equalTo: rightBarButton.leadingAnchor, constant: -10),
        ])
    }

    private func layoutPdfView() {
        pdfViewCenterYConstraint?.isActive = false
        pdfViewCenterYConstraint = pdfView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([
            pdfViewCenterYConstraint,
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            pdfView.trailingAnchor.constraint(equalTo: rightBarButton.leadingAnchor, constant: -10),
        ])
    }

    private func layoutCoachingOverlay() {
        NSLayoutConstraint.activate([
            coachingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coachingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coachingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            coachingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func layoutShowPartsButton() {
        NSLayoutConstraint.activate([
            showPartsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            showPartsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            showPartsButton.widthAnchor.constraint(equalToConstant: 80),
            showPartsButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}
