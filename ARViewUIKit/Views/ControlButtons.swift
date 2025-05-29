//
//  ControlButtons.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 14.04.25.
//

import UIKit

// Protocol for AR control actions
protocol ARControlDelegate: AnyObject {
    func didSelectControlMode(_ mode: ARControlMode)
}

// AR Control modes
enum ARControlMode: String, CaseIterable {
    case rotate = "rotate"
    case resize = "resize"
    case reset = "reset"
    case move = "move"
    
    var imageName: String {
        switch self {
        case .rotate:
            return "rotate"
        case .resize:
            return "resize"
        case .reset:
            return "reset"
        case .move:
            return "move"
        }
    }
}

class ControlButtons: UIView {
    private(set) var buttons: [UIButton] = []
    private var labels: [UILabel] = []
    private var selectedButton: UIButton?
    private var selectedLabel: UILabel?
    weak var delegate: ARControlDelegate?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        setupUI()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }
}

extension ControlButtons {
    func setupUI() {
        ARControlMode.allCases.forEach { mode in
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create button using the extension method
            let buttonImage = UIImage(named: mode.rawValue) ?? UIImage(systemName: mode.imageName)!
            let button = UIButton.createIconButton(
                image: buttonImage,
                tintColor: .white,
                backgroundColor: .clear
            )
            containerView.addSubview(button)
            buttons.append(button)
            
            // Create label for the button
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = mode.rawValue
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .white
            label.textAlignment = .center
            containerView.addSubview(label)
            labels.append(label)
            
            // Add button tag for identification
            if let index = ARControlMode.allCases.firstIndex(of: mode) {
                button.tag = index
            }
            
            // Add target action
            button.addTarget(self, action: #selector(controlButtonTapped(_:)), for: .touchUpInside)
            
            // Layout button and label in container
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: containerView.topAnchor),
                button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                button.heightAnchor.constraint(equalToConstant: 40),
                button.widthAnchor.constraint(equalToConstant: 40),
                
                label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 2),
                label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                
                containerView.widthAnchor.constraint(equalToConstant: 50)
            ])
            
            stackView.addArrangedSubview(containerView)
        }
        
        addSubview(stackView)
        
        // Select first button by default
        if let firstButton = buttons.first,
           let firstLabel = labels.first {
            selectButton(firstButton, withLabel: firstLabel)
        }
    }

    func layout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Actions

extension ControlButtons {
    @objc private func controlButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0 && index < buttons.count && index < labels.count else { return }
        
        selectButton(sender, withLabel: labels[index])
        
        let mode = ARControlMode.allCases[index]
        delegate?.didSelectControlMode(mode)
    }
}

// MARK: - Selection Helpers

extension ControlButtons {
    private func selectButton(_ buttonToSelect: UIButton, withLabel label: UILabel) {
        // Reset previous selection
        selectedButton?.tintColor = .white
        selectedLabel?.textColor = .white
        
        // Set new selection
        buttonToSelect.tintColor = .systemBlue
        label.textColor = .systemBlue
        
        selectedButton = buttonToSelect
        selectedLabel = label
    }
    
    func selectButton(at index: Int) {
        guard index >= 0 && index < buttons.count && index < labels.count else { return }
        selectButton(buttons[index], withLabel: labels[index])
    }
    
    func selectMode(_ mode: ARControlMode) {
        if let index = ARControlMode.allCases.firstIndex(of: mode),
           index < buttons.count && index < labels.count {
            selectButton(buttons[index], withLabel: labels[index])
        }
    }
}
