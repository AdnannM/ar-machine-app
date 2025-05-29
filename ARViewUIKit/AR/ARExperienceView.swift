//
//  ARExperienceView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 12.04.25.
//

import SwiftUI

struct ARViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some ARViewController {
        return ARViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
