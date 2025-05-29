//
//  Add3DModelViewModel.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 16.04.25.
//

import UIKit

// MARK: - ViewModel

final class Add3DModelViewModel {

    // Enum to differentiate the type of data the ViewModel manages
    enum ModelType {
        case machine
        case object
    }

    // Data source
    private(set) var models: [MachineModel] = []
    private let modelType: ModelType
    weak var delegate: Add3DModelViewDelegate?
    var viewIdentifier: Add3DModelView?

    init(type: ModelType) {
        self.modelType = type
        setupModels()
    }

    // Sets up dummy data based on the type
    private func setupModels() {
        switch modelType {
        case .machine:
            models = [
                MachineModel(id: "machine1", title: "Machine 1", image: UIImage(named: "machine1")),
                MachineModel(id: "machine2", title: "Machine 2", image: UIImage(named: "machine2")),
                MachineModel(id: "machine3", title: "Machine 3", image: UIImage(named: "machine3")),
                MachineModel(id: "machine4", title: "Machine 4", image: UIImage(named: "machine1"))
            ]
        case .object:
            models = [
                MachineModel(id: "Arrow", title: "Arrow", image: UIImage(named: "arrow")),
                MachineModel(id: "Pin", title: "Pin", image: UIImage(named: "pin")),
                MachineModel(id: "Warning", title: "Warning", image: UIImage(named: "danger")),
                MachineModel(id: "Arrow", title: "Arrow 2", image: UIImage(named: "arrow"))
            ]
        }
    }

    func modelCount() -> Int {
        return models.count
    }

    func model(at index: Int) -> MachineModel {
        return models[index]
    }

    // Forward actions to the delegate, passing the view identifier
    func didTapClear() {
        guard let view = viewIdentifier else { return }
        delegate?.clearButtonTapped(from: view)
    }

    func didTapClose() {
        guard let view = viewIdentifier else { return }
        delegate?.closeButtonTapped(from: view)
    }

    func didSelectModel(at index: Int) {
        guard let view = viewIdentifier else { return }
        let selectedModel = models[index]
        delegate?.modelSelected(selectedModel, from: view)
    }
}
