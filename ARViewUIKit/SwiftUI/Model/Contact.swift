//
//  Contact.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 05.05.25.
//

import Foundation

// MARK: - Models
struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let company: String
    let role: String
    let isPriority: Bool = true
    let isFavorite: Bool = true
    
    var displayRole: String {
        return role
    }
}

struct Machine: Identifiable {
    let id = UUID()
    let name: String
    let company: String
    let serialNumber: String
}
