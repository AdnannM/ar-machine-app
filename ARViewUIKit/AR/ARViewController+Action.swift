//
//  ARViewController+Action.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension adds menu control functionality to ARViewController.
         It handles opening and closing the menu, toggling the menu button icon,
         and animating the visibility of the right bar button when the menu state changes.
*/

import UIKit

extension ARViewController {
    @objc func toggleMenu() {
        isMenuOpened.toggle()
        menuButton.setImage(UIImage(
            named: isMenuOpened ? "close" : "menu"
        ), for: .normal)

        if isMenuOpened {
            rightBarButton.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.rightBarButton.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.rightBarButton.alpha = 0.0
            } completion: { _ in
                self.rightBarButton.isHidden = true
            }
        }
    }
}
