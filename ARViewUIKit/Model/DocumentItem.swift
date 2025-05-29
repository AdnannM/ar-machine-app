//
//  DocumentItem.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 17.04.25.
//

import Foundation

// Model for document items
struct DocumentItem {
    let title: String
    let fileType: String
    let creationDate: Date
    let fileURL: URL?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return "Created \(formatter.string(from: creationDate))"
    }
}
