//
//  Add3DModel.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 15.04.25.
//

import UIKit

// MARK: - Protocols

protocol Add3DModelViewDelegate: AnyObject {
    func clearButtonTapped(from view: Add3DModelView)
    func closeButtonTapped(from view: Add3DModelView)
    func modelSelected(_ model: MachineModel, from view: Add3DModelView)
}

// MARK: - View

class Add3DModelView: UIView {
    
    private let viewModel: Add3DModelViewModel

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Import 3D machine"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var clearAllButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Clear All"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 14, weight: .medium)
            return outgoing
        }
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var topBarStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), clearAllButton, closeButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(ModelTableViewCell.self, forCellReuseIdentifier: ModelTableViewCell.identifier)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 80
        return table
    }()

    // *** Initializer now takes a title ***
    init(viewModel: Add3DModelViewModel, title: String) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        // Pass self to ViewModel to identify sender in delegate calls
        self.viewModel.viewIdentifier = self
        self.titleLabel.text = title // Set the title

        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
        layer.cornerRadius = 20
        
        setupUI()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Consider making intrinsicContentSize dynamic or removing it
     override var intrinsicContentSize: CGSize {
         return CGSize(width: 400, height: 400)
     }

    // Optional: Add method to reload data if needed externally
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - Setup

extension Add3DModelView {
    private func setupUI() {
        addSubview(topBarStack)
        addSubview(tableView)

        clearAllButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            topBarStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            topBarStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topBarStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: topBarStack.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Actions
extension Add3DModelView {
    @objc private func didTapClearButton() {
        viewModel.didTapClear()
    }

    @objc private func didTapCloseButton() {
        viewModel.didTapClose()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension Add3DModelView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.modelCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ModelTableViewCell.identifier, for: indexPath) as? ModelTableViewCell else {
            // Fallback to a default cell instead of crashing
             print("Error dequeuing ModelTableViewCell")
             return UITableViewCell()
        }

        let model = viewModel.model(at: indexPath.row)
        cell.configure(with: model.title, image: model.image)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectModel(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true) // Deselect after tap
    }
}



