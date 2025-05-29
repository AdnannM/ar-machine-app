//
//  RightBarButtons.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 12.04.25.
//

import UIKit

protocol RightBarButtonsDelegate: AnyObject {
    func didTapAddButton()
    func didTapAddArrowButton()
    func didTapAddCubeButton()
    func didTapSignButton()
    func didTapLidarScannerButton()
    func didTapCameraButton()
    func didTapPdfButton()
    func didTapContactButton()
    func didTapInfoButton()
}

class RightBarButtons: UIView {
    
    // MARK: - Views
    
    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var add3DObjectButton: UIButton = {
        let customImage = UIImage(named: "addObject") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    private lazy var addArrow3DObjectButton: UIButton = {
        let customImage = UIImage(named: "addArrows") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    private lazy var addCube3DObjectButton: UIButton = {
        let customImage = UIImage(named: "addbox") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    private lazy var addSign3DObjectButton: UIButton = {
        let customImage = UIImage(named: "addSign") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    
    private lazy var addLidarScannerButton: UIButton = {
        let customImage = UIImage(named: "lidar") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    private lazy var addCameraButton: UIButton = {
        let customImage = UIImage(named: "camera") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    private lazy var addPdfButton: UIButton = {
        let customImage = UIImage(named: "pdf") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    private lazy var addContactButton: UIButton = {
        let customImage = UIImage(named: "contact") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    private lazy var addInfoButton: UIButton = {
        let customImage = UIImage(named: "info") ?? UIImage()
        let button = UIButton.createIconButton(image: customImage)
        return button
    }()
    
    // MARK: - Delegate
    
    weak var delegate: RightBarButtonsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .separator
        setupUI()
        laytou()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetupUI

extension RightBarButtons {
    
    private func setupUI() {
        
        /// Add StackView
        addSubview(verticalStack)
        
        /// Add Object
        verticalStack.addArrangedSubview(add3DObjectButton)
        add3DObjectButton.addTarget(self, action: #selector(add3DObjectButtonTapped), for: .touchUpInside)
    
        /// Add Arrow
        verticalStack.addArrangedSubview(addArrow3DObjectButton)
        addArrow3DObjectButton.addTarget(self, action: #selector(addArrow3DObjectButtonTapped), for: .touchUpInside)
        
        /// Add Box
        verticalStack.addArrangedSubview(addCube3DObjectButton)
        addCube3DObjectButton.addTarget(self, action: #selector(addCube3DObjectButtonTapped), for: .touchUpInside)
        
        /// Add Sign
        verticalStack.addArrangedSubview(addSign3DObjectButton)
        addSign3DObjectButton.addTarget(self, action: #selector(addSign3DObjectButtonTapped), for: .touchUpInside)
        
        /// Add Lidar Scanner
        verticalStack.addArrangedSubview(addLidarScannerButton)
        addLidarScannerButton.addTarget(self, action: #selector(addLidarScannerButtonTapped), for: .touchUpInside)
        
        /// Camere - Photos / Videos
        verticalStack.addArrangedSubview(addCameraButton)
        addCameraButton.addTarget(self, action: #selector(addCameraButtonTapped), for: .touchUpInside)
        
        /// Add Pdf
        verticalStack.addArrangedSubview(addPdfButton)
        addPdfButton.addTarget(self, action: #selector(addPdfButtonTapped), for: .touchUpInside)
        
        /// Add Contact
        verticalStack.addArrangedSubview(addContactButton)
        addContactButton.addTarget(self, action: #selector(addContactButtonTapped), for: .touchUpInside)
        
        /// Add Info
        verticalStack.addArrangedSubview(addInfoButton)
        addInfoButton.addTarget(self, action: #selector(addInfoButtonTapped), for: .touchUpInside)
    }
    
    private func laytou() {
        /// Stack View
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        /// Add Button
        NSLayoutConstraint.activate([
            add3DObjectButton.heightAnchor.constraint(equalToConstant: 40),
            add3DObjectButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Arrows
        NSLayoutConstraint.activate([
            addArrow3DObjectButton.heightAnchor.constraint(equalToConstant: 40),
            addArrow3DObjectButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Cube
        NSLayoutConstraint.activate([
            addCube3DObjectButton.heightAnchor.constraint(equalToConstant: 40),
            addCube3DObjectButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Sign
        NSLayoutConstraint.activate([
            addSign3DObjectButton.heightAnchor.constraint(equalToConstant: 40),
            addSign3DObjectButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Lidar Scanner
        NSLayoutConstraint.activate([
            addLidarScannerButton.heightAnchor.constraint(equalToConstant: 40),
            addLidarScannerButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Camera
        NSLayoutConstraint.activate([
            addCameraButton.heightAnchor.constraint(equalToConstant: 40),
            addCameraButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Pdf
        NSLayoutConstraint.activate([
            addPdfButton.heightAnchor.constraint(equalToConstant: 40),
            addPdfButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Contact
        NSLayoutConstraint.activate([
            addContactButton.heightAnchor.constraint(equalToConstant: 40),
            addContactButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        /// Add Info
        NSLayoutConstraint.activate([
            addInfoButton.heightAnchor.constraint(equalToConstant: 40),
            addInfoButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
    }
}


// MARK: - Action

extension RightBarButtons {

    @objc private func add3DObjectButtonTapped() {
        delegate?.didTapAddButton()
    }
    
    @objc private func addArrow3DObjectButtonTapped() {
        delegate?.didTapAddArrowButton()
    }
    
    @objc private func addCube3DObjectButtonTapped() {
        delegate?.didTapAddCubeButton()
    }
    
    @objc private func addSign3DObjectButtonTapped() {
        delegate?.didTapSignButton()
    }
    
    @objc private func addLidarScannerButtonTapped() {
        delegate?.didTapLidarScannerButton()
    }
    
    @objc private func addCameraButtonTapped() {
        delegate?.didTapCameraButton()
    }
    
    @objc private func addPdfButtonTapped() {
        delegate?.didTapPdfButton()
    }
    
    @objc private func addContactButtonTapped() {
        delegate?.didTapContactButton()
    }
    
    @objc private func addInfoButtonTapped() {
        delegate?.didTapInfoButton()
    }
}


