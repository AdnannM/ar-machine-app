//
//  Extension+Buttons.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 13.04.25.
//

import UIKit

extension UIButton {
    static func createIconButton(
        image: UIImage,
        tintColor: UIColor = .white,
        backgroundColor: UIColor = .separator,
        cornerRadius: CGFloat = 12
    ) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.tintColor = tintColor
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        return button
    }
}


extension UIViewController {
    func presentAsSheet(
        _ viewController: UIViewController,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        prefersGrabberVisible: Bool = true,
        preferredCornerRadius: CGFloat = 20
    ) {
        viewController.modalPresentationStyle = .pageSheet

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = prefersGrabberVisible
            sheet.preferredCornerRadius = preferredCornerRadius
        }

        present(viewController, animated: true, completion: nil)
    }
}


extension UIButton {
    static func makeActionButton(
        systemName: String,
        target: Any?, // Add this parameter
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 20
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        button.addTarget(target, action: action, for: .touchUpInside) // Use the provided target
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return button
    }
}
