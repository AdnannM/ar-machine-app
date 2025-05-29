//
//  InfoListViewModel.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 15.04.25.
//

import Foundation

// MARK: - View Models
final class InfoListViewModel {
    // Data source
    private(set) var items: [InfoItem] = [
        InfoItem(iconName: "addObject", title: "Import 3D machines", subtitle: "Import machine into the environment"),
        InfoItem(iconName: "addArrows", title: "Import 3D object", subtitle: "Import object into the environment"),
        InfoItem(iconName: "addbox", title: "Highlight machine parts", subtitle: "Lets you highlight machine parts and see already highlighted ones."),
        InfoItem(iconName: "addSign", title: "Simulator", subtitle: "Simulate the machine in motion"),
        InfoItem(iconName: "lidar", title: "Lidar", subtitle: "Scan objects and the environment"),
        InfoItem(iconName: "camera", title: "Video recording", subtitle: "Capture an image or record a video"),
        InfoItem(iconName: "pdf", title: "Documents", subtitle: "Lets you search and view related documents."),
        InfoItem(iconName: "contact", title: "Contact", subtitle: "Send direct message or make a video call")
    ]
    
    // Callback when an item is selected
    var onItemSelected: ((InfoItem) -> Void)?
    
    func item(at index: Int) -> InfoItem {
        return items[index]
    }
    
    func numberOfItems() -> Int {
        return items.count
    }
    
    func didSelectItem(at index: Int) {
        onItemSelected?(items[index])
    }
}
