//
//  ARViewController+PdfViewDelegate.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension makes ARViewController conform to the PdfViewDelegate protocol.
         It handles search interactions by adjusting the PDF view's vertical position,
         presents selected documents in a sheet using PdfViewController,
         and manages dismissing the PDF view when needed.
*/

import UIKit

extension ARViewController: PdfViewDelegate {
    func searchDidBeginEditing() {
        pdfViewCenterYConstraint.constant = -90
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func searchDidEndEditing() {
        // Move the PDF view back to center
        pdfViewCenterYConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func documentSelected(_ document: DocumentItem) {
        let vc = PdfViewController()
        vc.pdfURL = document.fileURL
        presentAsSheet(vc, detents: [.large()])
    }
    
    func dismissView() {
        pdfView.isHidden = true
    }
}
