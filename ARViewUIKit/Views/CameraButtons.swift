//
//  CameraButtons.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 14.04.25.
//

import UIKit

protocol CameraButtonsDelegate: AnyObject {
    func cameraButtonPressed()
    func cameraRecordingButtonPressed()
    func previewImageTapped()
}

class CameraButtons: UIView {
    
    // MARK: - UI Elements
    
    // Preview area on the left
    let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true // Enable interaction
        return imageView
    }()
    
    // Button specifically for taking photos
    let takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        button.layer.cornerRadius = 30
        if let icon = UIImage(systemName: "camera.fill") {
            button.setImage(icon, for: .normal)
            button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .medium), forImageIn: .normal)
        }
        return button
    }()
    
    // Button specifically for recording video
    let recordVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        button.layer.cornerRadius = 30
        if let icon = UIImage(systemName: "record.circle") {
            button.setImage(icon, for: .normal)
            button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .medium), forImageIn: .normal)
        }
        return button
    }()
    
    // Stack view to hold the photo and video buttons
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 25
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    weak var delegate: CameraButtonsDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set a background for the whole view if needed
         backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        setupUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePreviewImage(image: UIImage?) {
        previewImageView.image = image
        // Set background/interaction state based on image presence
        previewImageView.backgroundColor = (image == nil) ? .darkGray : .clear
        previewImageView.isUserInteractionEnabled = (image != nil)
    }
}

// MARK: - Setup and Layout

extension CameraButtons {
    private func setupUI() {
        // Add subviews
        addSubview(previewImageView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappPreviewImageView))
        previewImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add buttons to the stack view
        buttonsStackView.addArrangedSubview(takePhotoButton)
        takePhotoButton.addTarget(self, action: #selector(didTappCameraButton), for: .touchUpInside)
        
        buttonsStackView.addArrangedSubview(recordVideoButton)
        recordVideoButton.addTarget(self, action: #selector(didTappRecordingButton), for: .touchUpInside)
        
        // Add the stack view to the main view
        addSubview(buttonsStackView)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            // Preview ImageView (Left Side)
            previewImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            previewImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            previewImageView.widthAnchor.constraint(equalToConstant: 75),
            previewImageView.heightAnchor.constraint(equalToConstant: 100),
            
            buttonsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
     
            takePhotoButton.widthAnchor.constraint(equalToConstant: 60),
            takePhotoButton.heightAnchor.constraint(equalTo: takePhotoButton.widthAnchor),
            
            recordVideoButton.widthAnchor.constraint(equalToConstant: 60),
            recordVideoButton.heightAnchor.constraint(equalTo: recordVideoButton.widthAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
    }
}

// MARK:  Helper to update record button state

extension CameraButtons {
    func setRecordingState(isRecording: Bool) {
        let iconName = isRecording ? "stop.circle.fill" : "record.circle"
        let tintColor: UIColor = isRecording ? .white : .red // Change tint/background maybe
        let backgroundColor: UIColor = isRecording ? .red : UIColor.darkGray.withAlphaComponent(0.6)
        
        if let icon = UIImage(systemName: iconName) {
            recordVideoButton.setImage(icon, for: .normal)
            recordVideoButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .medium), forImageIn: .normal)
            recordVideoButton.tintColor = tintColor
            recordVideoButton.backgroundColor = backgroundColor
        }
    }
}

// MARK: - Actions

extension CameraButtons {
    @objc private func didTappCameraButton() {
        delegate?.cameraButtonPressed()
    }
    
    @objc private func didTappRecordingButton() {
        delegate?.cameraRecordingButtonPressed()
    }
    
    @objc private func didTappPreviewImageView() {
        delegate?.previewImageTapped()
    }
}
